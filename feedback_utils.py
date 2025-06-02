# Copyright (c) 2025 Pankaj Pansari
# See the LICENSE file for details.

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

from dotenv import load_dotenv
from openai import OpenAI
from openai.types.chat import ChatCompletion
from pydantic import BaseModel, Field
from unidiff import PatchSet


class Config:
    """Loads pathnames and LLM model-string from env config file.

    Attributes:
      problem_statement: pathname to file containing detailed assignment description.
      rubric: pathname to file containing detailed rubric (what are the parameters
         of qualitative eval)
      input_dir: high-level folder where input data is present. Should be 'input/'
        by default. Can contain subfolders.
      output_dir: high-level folder where output data will go. Should be 'output/'
        by default. Subdirectory structure preserved.
      inter_dir: high-level folder where intermediate data will go. Should be
        'intermediates/' by default. Subdirectory structure preserved.
      proposer_reviewer: the string representing the OpenAI model to be used.
    """

    def __init__(self, input_path: Path, env_file: str = "config_repo.env") -> None:
        """Initializes the instance based on .env config file

        Args:
          env_file: path to the .env config file
          input_path: Path object containing relative path to submission,
            whether submission is a single file or a (target) repository
        """
        load_dotenv(dotenv_path=env_file)  # Load config.env file
        # File paths
        self.problem_statement = os.getenv("PROBLEM_STATEMENT")
        self.rubric = os.getenv("RUBRIC")
        self.proposer_reviewer = os.getenv(
            "PROPOSER_REVIEWER"
        )  # LLM model string (get it from OpenAI API docs)
        self.summarizer = ""
        if "SUMMARIZER" in os.environ:
            self.summarizer = os.getenv(
                "SUMMARIZER"
            )  # LLM model string (get it from OpenAI API docs)
        self.intermediate_path = get_intermediate_path(input_path)
        self.output_path = get_output_path(input_path)
        self.input_path = Path("")


# ===================== UTILS ====================================
def get_intermediate_path(input_path: Path):
    """Return the folder path where intermediate results go"""
    if input_path.is_file():
        return Path("intermediates" / input_path.parent.relative_to("input"))
    else:
        return Path("intermediates" / input_path.relative_to("input"))


def get_output_path(input_path: Path):
    """Return the folder path where final output feedback should go"""
    if input_path.is_file():
        return Path("output" / input_path.parent.relative_to("input"))
    else:
        return Path("output" / input_path.relative_to("input"))


def write_log(
    response: ChatCompletion, id_str: str, input_filename: str, config: Config
) -> None:
    """Write number of input/cached/output tokens per API call with timestamp to
    log file

    Args:
      response: object returned by OpenAI API call
      id_str: identity the component doing logging (either Proposer or Reviewer)
      input_filename: full pathname of the program file
      config: instance of Config class that specifies paths and LLM model type

    Returns:
      None

    Reviewer appends to the same log file. This logging lets us monitor prompt
    caching.
    """
    log_file = config.intermediate_path / f"{input_filename.stem}_log.txt"

    # If file exists before first log write during this call, overwrite it
    permission = "w" if id_str == "Proposer" else "a"

    with open(log_file, permission, encoding="utf-8") as f:
        response_dict = response.model_dump()
        cached_tokens = response_dict["usage"]["input_tokens_details"]["cached_tokens"]
        prompt_tokens = response_dict["usage"]["input_tokens"]
        output_tokens = response_dict["usage"]["output_tokens"]
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(
            f"{timestamp} : {id_str} Input / Cached / Output tokens: {prompt_tokens}: "
            f"/ {cached_tokens} / {output_tokens}\n"
        )


def preprocess_program(
    input_filename: Path, config: Config, hunk_set: Set = None
) -> Path:
    """Write to output file a processed text of program indicating line numbers
    and marking modified/added lines with a '+' symbol.
    For single file submission, all lines are prepended by '+' symbol along with
    line number.

    This makes it easier for the LLM to tell us where the annotations will be placed

    Args:
        input_filename: Path object with relative path to input program file
        hunk_set: A Set object containing all line numbers that are new/modified
            in program file in target repo with respect to source repo
        config: instance of Config class that specifies paths and LLM model type

    Returns:
        Path object with relative path to output file (same extension as input)
    """
    processed_input_filename = config.intermediate_path / f"{input_filename.name}"

    with open(input_filename, "r", encoding="utf-8") as f_input, open(
        processed_input_filename, "w"
    ) as f_processed_input:
        i = 0
        for line in f_input:
            i += 1
            if hunk_set is not None and i not in hunk_set:
                f_processed_input.write(f"{i} | {line}")
            else:
                f_processed_input.write(f"{i} | + {line}")

    return processed_input_filename


# ========================= STRUCTURED OUTPUT SCHEMA ================


class Annotation(BaseModel):
    """Represents a single annotation with line-specific feedback. Used by OpenAI API
    for structured output.

    Attributes:
      line_number: for which line in program file is this annotation for
      category: which evaluation parameter does this feedback pertain to
      comment: detailed explanation of issue or suggestion
      severity: degree of importance of this annotation
    """

    line_number: int
    category: str = Field(
        description="category: one of code_readability, language_convention, "
        "program_design, data_structures, pointers_memory"
    )
    comment: str = Field(description="Detailed feedback about code at this line number")
    severity: str = Field(
        description="Level of importance: 'suggestion', 'issue', or 'critical'"
    )


# ==========================PROMPT TEMPLATES===================================
def create_common_prompt_str(
    problem_statement: str, rubric: str, submission_program: str
) -> str:
    """Common part of the prompt to Proposer and Reviewer. Benefits from prompt caching.

    Args:
      problem_statement: string read from the problem description file
      rubric: string read for the rubric file
      submission_program: string of the program in a processed format

    Returns:
        common initial part of prompt as string
    """

    return f"""For a programming assignment, below are the problem statement, rubric
    for code quality feedback, and program submission. For easier processing, the lines
    in the program have been prepended by line number like '42 | int a;'. A '+' 
    marks those lines that have been added by the programmer.  

     <problem_statement>
     {problem_statement}
     </problem_statement>

     <rubric>
     {rubric}
     </rubric>

     <submission>
     {submission_program}
     </submission>
     
     If all lines are marked by '+', it can either mean that the submission is
     in form of a single code file, or that the file is a new addition to the
     target_repo (not present in source_repo). If only some lines are marked by '+'
     it implies that the existing code in source_repo has been modified.

     So, if submission is a target repo, please note that this particular program
     file is only a part of the solution of the assignment.

    Suggest a list of annotations (comments) of feedback based on the rubric. 
    Also give a summary. Adhere to the structured output schema.
     """


def create_proposer_prompt(
    problem_statement: str, rubric: str, submission_program: str
) -> str:
    return (
        create_common_prompt_str(problem_statement, rubric, submission_program)
        + "Suggest a list of annotations (comments) of feedback based on "
        "the rubric. Adhere to the structured output schema. If only some lines "
        "have been added to an existing program file in source_repo (marked by '+'), "
        "then give feedback only on the modified lines. It's okay to not give any "
        "feedback if there isn't a strong need for one. For single program file "
        "submissions, also generate a summary feedback"
    )


def create_reviewer_prompt(
    problem_statement: str,
    rubric: str,
    submission_program: str,
    proposal_json: str,
    linter_summary: str = None,
) -> str:

    reviewer_prompt = (
        create_common_prompt_str(problem_statement, rubric, submission_program)
        + f"Look at the following list of annotations and the summary of "
        "feedback.PatchSet Do the following:"
        "1. For each annotation, check if line number is correct and if "
        "annotation is useful to give and valid"
        "2. Incorporate the linter output in annotations and summary, if needed."
        "3. Discard annotations which are not very helpful and may clutter."
    )

    if linter_summary:
        reviewer_prompt += (
            f"Clang-tidy linter gave the following output (summary) for the submission."
            "<linter>"
            f"{linter_summary}"
            "</linter>"
        )

    reviewer_prompt += (
        "Look at the following list of annotations and the summary of feedback. "
        "Note summary is present only for single program file submissions, "
        "and not for repo submissions. Do the following:"
        "1. For each annotation, check if line number is correct and if "
        "annotation is useful to give and valid. "
        "2. Incorporate the linter output in annotations and summary, if needed. "
        "Note these are available only for single file submissions, not for repo"
        "submissions. "
        "3. Discard annotations which are not very helpful and may clutter. "
        "<feedback>"
        f"{proposal_json}"
        "</feedback>"
    )

    return reviewer_prompt


def create_system_prompt():
    return (
        "Your role is to act as an OS course TA who provides qualitative "
        "feedback on student C programming assignment. Feedback is good when it is "
        "relevant for education of undergraduate computer science students, and it "
        "is not overwhelming in quantity. Please stick to the rubric."
    )
