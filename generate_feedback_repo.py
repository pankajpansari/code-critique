# Copyright (c) 2025 Pankaj Pansari
# See the LICENSE file for details.

"""Generate feedback for assignment submission. Submission consists of additions
and modifications to an existing codebase (source repo), resulting in target repo.

We generate feedback for each individual modified or added file separately; these
files are identified by diffing source and target repos. The feedback for each
such file is written in a common feedback output file. The script first calls
Proposer to generate initial feedback for each modified/added file, giving problem
statement and rubric (what make good quality code?) as context. A reviewer then
reflects on these annotations to generate final feedback.

Please make sure that config_repo.env contains appropriate path values.

Typical usage example:

$ python3 scripts/generate_feedback_repo.py input/threads-in-xv6-submission input/xv6-public
"""

import argparse
import datetime
import json
import os
import shutil
import subprocess
import sys
import textwrap
from pathlib import Path
from typing import List, Set

from feedback_utils import (
    Annotation,
    Config,
    create_proposer_prompt,
    create_reviewer_prompt,
    create_system_prompt,
    preprocess_program,
    write_log,
)
from openai import OpenAI
from openai.types.chat import ChatCompletion
from pydantic import BaseModel, Field
from unidiff import PatchSet

THRESHOLD = 10  # Give feedback on files with at least THRESHOLD modifications/additions
DEFAULT_WRAP_WIDTH = 80
ANNOTATION_PREFIX = "/* \n * REVIEW: "
ANNOTATION_SUFFIX = "\n */"
PROGRAM_LANG = ".c"  # What is the programming language of submission?

client = None
# ===================== UTILS ====================================


def run_diff(source_repo: Path, target_repo: Path, config: Config) -> Path:
    """Runs diff tool between source and target repos.
    Output is in unified diff format.

    Args:
        source_repo: Path object containing relative path to source repo.
        target_repo: Path object containing relative path to target repo.
        config: Instance of Config class that gives path to problem statement

    Returns:
        diff_filename: Path object containing relative path to diff file.
    """
    process = subprocess.Popen(
        ["diff", "-r", "-u", source_repo, target_repo],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    diff_out, diff_err = process.communicate()
    if process.returncode == 2:  # diff returns 2 if there's some error
        print(f"Error running diff: {diff_err}")
        sys.exit(1)

    diff_filename = config.intermediate_path / "repo.diff"

    with open(diff_filename, "w", encoding="utf-8") as f:
        f.write(diff_out)

    return diff_filename


# ========================= STRUCTURED OUTPUT SCHEMA ================
class FeedbackResponse(BaseModel):
    """Represents list of annotations with line-specific feedback. Used by OpenAI API
    for structured output.

    Attributes:
        annotations: List of Annotation objects
    """

    annotations: list[Annotation] = Field(
        description="List of line-specific code feedback"
    )


def call_proposer(
    problem_statement: str,
    rubric: str,
    submission_program: str,
    input_filename: Path,
    config: Config,
) -> None:
    """Proposer generates a first draft of annotations.

    Makes LLM API call, passes the detailed problem statement and evaluation rubric
    as context; requests LLM to give feedback in structured output format for the
    current program file. Writes the LLM output to a json file in intermediates/
    dir, for use by Reviewer

    Arg:
      problem_statement: string read from the problem description file
      rubric: string read for the rubric file, which is a detailed specification
        of what makes good quality code
      submission_program: string of the program in a processed format. Processing
        consists of prepending all lines with line numbers and only newly added lines
        (with respect to source_repo) with '+'
      input_filename: Path object containing the relative path of program file
      config: Instance of Config class that gives path to problem statement

    Return:
      None
    """

    user_prompt = create_proposer_prompt(problem_statement, rubric, submission_program)
    system_prompt = create_system_prompt()

    try:
        proposer_response = client.responses.parse(
            model=config.proposer_reviewer,
            input=[
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": user_prompt,
                },
            ],
            text_format=FeedbackResponse,
        )
    except Exception as api_error:
        print(f"API call error for proposer: {str(api_error)}")
        sys.exit(1)

    initial_feedback = proposer_response.output_parsed

    json_file = config.intermediate_path / f"{input_filename.stem}_intermediate.json"

    with open(json_file, "w") as f:
        json.dump(initial_feedback.model_dump(), f, indent=4, ensure_ascii=False)

    write_log(proposer_response, "Proposer", input_filename, config)


def call_reviewer(
    problem_statement: str,
    rubric: str,
    submission_program: str,
    input_filename: Path,
    config: Config,
) -> None:
    """Reviewer reviews the feedback generated by Proposer.

    Note that if you want to integrate linter output, please make use of run_linter
    from generate_feedback_single.py Include processed linter summary in prompt
    to reviewer.

    Arg:
      problem_statement: string read from the problem description file
      rubric: string read for the rubric file, which is a detailed specification
        of what makes good quality code
      submission_program: string of the program in a processed format. Processing
        consists of prepending all lines with line numbers and only newly added
        lines (with respect to source_repo) with '+'
      input_filename: Path object containing the relative path of program file
      config: Instance of Config class that gives path to problem statement

    Return:
      None
    """

    json_file = config.intermediate_path / f"{input_filename.stem}_intermediate.json"

    try:
        with open(json_file, "r", encoding="utf-8") as f:
            proposer_output_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {json_file} not found")
        sys.exit(1)

    proposal_json = json.dumps(proposer_output_data)

    user_prompt = create_reviewer_prompt(
        problem_statement, rubric, submission_program, proposal_json
    )
    system_prompt = create_system_prompt()

    try:
        reviewer_response = client.responses.parse(
            model=config.proposer_reviewer,
            input=[
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": user_prompt,
                },
            ],
            text_format=FeedbackResponse,
        )
    except Exception as api_error:
        print(f"API call error for proposer: {str(api_error)}")
        sys.exit(1)

    refined_feedback = reviewer_response.output_parsed

    json_file = config.intermediate_path / f"{input_filename.stem}_final.json"

    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(refined_feedback.model_dump(), f, indent=4, ensure_ascii=False)

    write_log(reviewer_response, "Reviewer", input_filename, config)


def postprocess(input_filename: Path, config: Config) -> None:
    """Write all annotations for this program file in feedback file. Localize
    each feedback with line number and corresponding program text at this line number.

    For repo feedback, postprocessing is simple. Feedback file is common for
    whole repo. First write the name of program file for these annotations. Then
    write each feedback.

    Args:
      input_filename: Path object containing relative path of program file
      config: Instance of Config class that gives path to problem statement

    Return:
      None
    """
    json_file = config.intermediate_path / f"{input_filename.stem}_final.json"

    with open(json_file, "r", encoding="utf-8") as f:
        json_content = json.load(f)

    # If there are no annotations, skip writing to output file
    if len(json_content["annotations"]) == 0:
        return

    annotation_dict = {}
    for annotation in json_content["annotations"]:
        line_number = annotation["line_number"]
        comment = annotation["comment"]
        wrapped_lines = textwrap.wrap(
            comment, width=DEFAULT_WRAP_WIDTH
        )  # Wrap annotations for better readability
        formatted_comment = (
            ANNOTATION_PREFIX + " \n * ".join(wrapped_lines) + ANNOTATION_SUFFIX
        )
        annotation_dict[int(line_number)] = formatted_comment

    output_filename = config.output_path / Path(f"feedback{PROGRAM_LANG}")

    with open(input_filename, "r", encoding="utf-8") as f_input, open(
        output_filename, "a", encoding="utf-8"
    ) as f_output:
        f_output.write(
            f"\n/*============================{input_filename.name}============="
            f"============================/*\n"
        )
        i = 0
        for line in f_input:
            i += 1
            if i in annotation_dict:
                comment = annotation_dict[i]
                comment = "\n" + comment + "\n"
                f_output.write(comment)
                f_output.write(f"line {i}: {line[2:]}")


def generate_file_feedback(input_filename: Path, config: Config) -> None:
    """Generates and writes feedback for this program file.

    Calls Proposer, Reviewer, and postprocessing modules in sequence.

    Args:
      input_filename: Path object containing relative path of program file
      config: Instance of Config class that gives path to problem statement
        and rubric.
    Returns:
      None
    """
    try:
        with open(config.problem_statement, "r", encoding="utf-8") as f:
            problem_statement = f.read()
    except FileNotFoundError:
        print(f"Error: {config.problem_statement} not found")
        sys.exit(1)

    try:
        with open(config.rubric, "r", encoding="utf-8") as f:
            rubric = f.read()
    except FileNotFoundError:
        print(f"Error: {config.rubric} not found")
        sys.exit(1)

    with open(input_filename, "r", encoding="utf-8") as f:
        submission_program = f.read()
    call_proposer(problem_statement, rubric, submission_program, input_filename, config)
    call_reviewer(problem_statement, rubric, submission_program, input_filename, config)

    postprocess(input_filename, config)

    print(f"Feedback generation complete for {input_filename}. Output saved.")


def main() -> None:
    """Given relative paths to source and target repos, generate feedback for
    this submission in two parts. A target repo consists of modifications made
    to files in source repo, along with completely new program files not present
    in source repo.

    To identify newly added files and modified files, we run diff tool between
    source and target repo and generate diff output in unified format.

    The newly added files and modified files are handled separately in this main
    function, but the pipeline is essentially identical.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("source_repo_path", help="Path of original repo (source)")
    parser.add_argument("target_repo_path", help="Path of modified repo (target)")
    args = parser.parse_args()
    source_repo = Path(args.source_repo_path)
    target_repo = Path(args.target_repo_path)

    config = Config(target_repo, "config_repo.env")

    global client
    client = OpenAI()

    # Clear existing contents under intermediates/ and output/
    if os.path.exists(config.intermediate_path):
        shutil.rmtree(config.intermediate_path)
    if os.path.exists(config.output_path):
        shutil.rmtree(config.output_path)

    # Create destination folders under intermediates/ and output/
    os.makedirs(config.intermediate_path, exist_ok=True)
    os.makedirs(config.output_path, exist_ok=True)

    diff_filename = run_diff(source_repo, target_repo, config)

    # Generate feedback for new files (files only in target_repo)
    target_str = "Only in " + str(target_repo)
    with open(diff_filename, "r", encoding="utf-8") as f:
        for line in f:
            if target_str in line:
                filename = line.split()[-1]
                if filename.endswith(PROGRAM_LANG):
                    input_filename = target_repo / filename
                    processed_input_filename = preprocess_program(
                        input_filename, config
                    )
                    generate_file_feedback(processed_input_filename, config)

    # Generate feedback for modified files
    patch = PatchSet.from_filename(diff_filename)
    for p in patch:
        if Path(p.source_file).suffix == PROGRAM_LANG:
            hunk_set = set()

            for hunk in p:
                for i in range(hunk.target_length):
                    hunk_set.add(hunk.target_start + i)

            if len(hunk_set) < THRESHOLD:
                continue

            input_filename = Path(p.target_file)
            processed_input_filename = preprocess_program(
                input_filename, config, hunk_set
            )
            generate_file_feedback(processed_input_filename, config)


if __name__ == "__main__":
    main()
