# Copyright (c) 2025 Pankaj Pansari
# See the LICENSE file for details.

"""Generate feedback for assignment submission. Submission consists a single
program file. If the submission is in form of a repo of multiple files, consider
using generate_feedback_repo.py

The feedback for program file is written in a feedback output file.
The script first calls Proposer to generate initial feedback, giving problem
statement and rubric (what make good quality code?) as context. A reviewer then
reflects on these annotations to generate final feedback and also integrates
output from clang-tidy linter run on the program file.

Please make sure that config.env contains appropriate path values.

Typical usage example:

$ python3 scripts/generate_feedback.py input/example/single_file_submission/wish.c
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

from openai import OpenAI
from pydantic import BaseModel, Field

from feedback_utils import (
    Annotation,
    Config,
    create_proposer_prompt,
    create_reviewer_prompt,
    create_system_prompt,
    preprocess_program,
    write_log,
)

DEFAULT_WRAP_WIDTH = 80
ANNOTATION_PREFIX = "/* \n * REVIEW: "
ANNOTATION_SUFFIX = "\n */"
PROGRAM_LANG = ".c"  # What is the programming language of submission?

client = None

# ===================== UTILS ====================================


def run_linter(input_filename: Path, config: Config) -> str:
    """Calls clang-tidy linter on the C program file and makes LLM call to
        summarize the linter output in a more readable format.

    It helps to use LLM as summarizer since otherwise linter output is cluttered
        with pathnames.

    Args:
        input_filename: Path object containing relative path to the program file
            submission
        config: Instance of Config class that specifies the model of summary LLM

    Returns:
        summary of linter output as string.
    """
    process = subprocess.Popen(
        ["clang-tidy", str(input_filename), "--", "-std=gnu11"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    linter_output, error_output = process.communicate()

    linter_filename = config.intermediate_path / f"{input_filename.stem}_linter_out.txt"

    with open(linter_filename, "w") as f:
        f.write(linter_output)

    if process.returncode != 0:
        print(f"clang-tidy exited with code {process.returncode}: {error_output}")
        sys.exit(1)

    try:
        response = client.responses.create(
            model=config.summarizer,
            input=[
                {
                    "role": "user",
                    "content": f"The following is output from a linter. Please "
                    f"retain the essential points only. These will be used "
                    f"to guide an LLM-based automated programming feedback tool",
                },
                {"role": "user", "content": linter_output},
            ],
        )
    except Exception as api_error:
        print(f"API call error for proposer: {str(api_error)}")
        sys.exit(1)

    return response.output_text


# ========================= STRUCTURED OUTPUT SCHEMA ================
class Summary(BaseModel):
    """Pydantic class representing feedback summary. Summary comprises
    good aspects of implementation, what can be improved, and overall
    assessment.

    The role of summary is to succinctly capture certain feedback that
    cannot be inserted at specific lines but are more general.

    Attributes:
        strengths: a string containing details of good implementation
        areas_for_improvement: a string containing details of improvements to be
            made overall_assessment: a summary of feedback
    """

    strengths: str = Field(
        description="Description of positive aspects of the submission"
    )
    areas_for_improvement: str = Field(
        description="Description of aspects that need improvement"
    )
    overall_assessment: str = Field(
        description="Brief overall evaluation of the submission"
    )


class FeedbackResponse(BaseModel):
    """Represents list of feedback annotations and a summary."""

    annotations: list[Annotation] = Field(
        description="List of line-specific code feedback"
    )
    summary: Summary = Field(description="Overall assessment of the submission")


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
        consists of prepending all lines with line numbers and only newly added
        lines (with respect to source_repo) with '+'
      input_filename: Path object containing the relative path of program file
      config: instance of Config class that specifies intermediate path and model
        of LLM to use

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
        return f"API call error for proposer: {str(api_error)}"

    initial_feedback = proposer_response.output_parsed

    json_file = config.intermediate_path / f"{input_filename.stem}_intermediate.json"

    with open(json_file, "w") as f:
        json.dump(initial_feedback.model_dump(), f, indent=4, ensure_ascii=False)

    write_log(proposer_response, "Proposer", input_filename, config)


def call_reviewer(
    problem_statement: str,
    rubric: str,
    submission_program: str,
    linter_summary: str,
    input_filename: Path,
    config: Config,
) -> None:
    """Reviewer reviews the feedback generated by Proposer and integrates output
    from clang-tidy linter.

    Arg:
      problem_statement: string read from the problem description file
      rubric: string read for the rubric file, which is a detailed specification
        of what makes good quality code
      submission_program: string of the program in a processed format. Processing
        consists of prepending all lines with line numbers and '+'
      linter_summary: string containing clean summary of clang-tidy linter output
      input_filename: Path object containing the relative path of program file
      config: instance of Config class that specifies paths and LLM model type

    Return:
      None
    """

    json_file = config.intermediate_path / f"{input_filename.stem}_intermediate.json"

    try:
        with open(json_file, "r") as f:
            proposer_output_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {json_file} not found")
        sys.exit(1)

    proposal_json = json.dumps(proposer_output_data)

    user_prompt = create_reviewer_prompt(
        problem_statement, rubric, submission_program, proposal_json, linter_summary
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

    with open(json_file, "w") as f:
        json.dump(refined_feedback.model_dump(), f, indent=4, ensure_ascii=False)

    write_log(reviewer_response, "Reviewer", input_filename, config)


def postprocess(input_filename: Path, config: Config):
    """Insert feedback comments at the correct point in original code and appends
    a summary at the end. This leaves the original lines of code unchanged; only
    feedback has been merged at appropriate points and there is summary at end.

    Args:
      input_filename: Path object containing relative path of program file
      config: instance of Config class that specifies paths and LLM model type

    Return:
      None
    """

    json_file = config.intermediate_path / f"{input_filename.stem}_final.json"

    with open(json_file, "r", encoding="utf-8") as f:
        json_content = json.load(f)

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

    output_filename = config.output_path / Path(
        input_filename.stem + "_feedback" + input_filename.suffix
    )

    with open(input_filename, "r", encoding="utf-8") as f_input, open(
        output_filename, "a", encoding="utf-8"
    ) as f_output:
        i = 0
        for line in f_input:
            i += 1
            if i in annotation_dict:
                comment = annotation_dict[i]
                comment = "\n" + comment + "\n"
                f_output.write(comment)
            f_output.write(line)

    summary = json.dumps(json_content["summary"])

    try:
        response = client.responses.parse(
            model=config.summarizer,
            input=[
                {
                    "role": "user",
                    "content": "The following is summary of feedback on a "
                    f"{PROGRAM_LANG} program from an automated tool. First, summarize "
                    "it nicely so I can append it at the bottom of submission. Then "
                    f"format it properly as  {PROGRAM_LANG} comment block; try to "
                    "respect 80 character line limit convention. Do not add any "
                    "suggestions of your own; Give output in structured format "
                    f"respecting the given schema..\n<summary>\n {summary} \n</summary>",
                }
            ],
            text_format=Summary,
        )
    except Exception as api_error:
        print(f"API call error for proposer: {str(api_error)}")
        sys.exit(1)

    write_log(response, "Summarizer", input_filename, config)

    summary = response.output_parsed

    with open(output_filename, "a", encoding="utf-8") as f_output:
        f_output.write("\n/*")
        for summary_field_name, summary_field_value in summary.__dict__.items():
            formatted_name = summary_field_name.upper().replace("_", " ")
            f_output.write(f"\n *\n * {formatted_name}: \n *")
            wrapped_lines = textwrap.wrap(
                summary_field_value, width=DEFAULT_WRAP_WIDTH
            )  # Wrap summary text for better readability
            f_output.write(" \n * ".join(wrapped_lines))
        f_output.write(f"\n*/")


def generate_file_feedback(
    input_filename: Path, linter_summary: str, config: Config
) -> None:
    """Generates and writes feedback for this program file.

    Calls Proposer, Reviewer, and postprocessing modules in sequence.

    Args:
      input_filename: Path object containing relative path of program file
      linter_summary: string containing clean summary of clang-tidy linter output
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
    call_reviewer(
        problem_statement,
        rubric,
        submission_program,
        linter_summary,
        input_filename,
        config,
    )


def main():
    """Given relative paths to program file submission, generate feedback for
    this submission. Feedback consists of annotations inserted at appropriate
    programs in program plus a summary at the end. The code lines remain unchanged.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("program_filepath", help="Path of program file to be evaluated")
    args = parser.parse_args()
    input_filename = Path(args.program_filepath)

    config = Config(input_filename, "config_single.env")

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

    # Run linter on program file and summarize linter output
    linter_summary = run_linter(input_filename, config)

    processed_input_filename = preprocess_program(input_filename, config)
    generate_file_feedback(processed_input_filename, linter_summary, config)

    postprocess(input_filename, config)
    print(f"Feedback generation complete for {input_filename}. Output saved.")


if __name__ == "__main__":
    main()
