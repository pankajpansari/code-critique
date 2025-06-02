# Automated Programming Assignment Feedback Tool

Welcome! This tool is designed to provide automated, insightful feedback on programming assignments. By leveraging the power of Large Language Models (LLMs) and static analysis, it aims to offer comprehensive suggestions and help students improve their coding skills.

## Core Scripts

### `generate_feedback_repo.py`

This script is designed for multi-file programming assignments. It analyzes the submitted repository, generates diffs against a source/template repository, and utilizes a Proposer/Reviewer LLM architecture to provide feedback on the changes.

### `generate_feedback_single.py`

This script is tailored for single-file programming assignments. It employs Proposer/Reviewer LLMs to analyze the submission and integrates output from static analysis tools like `clang-tidy` to offer a comprehensive review.

## Utility Module

### `feedback_utils.py`

This module contains shared utility functions and data models that support the main feedback generation scripts (`generate_feedback_repo.py` and `generate_feedback_single.py`). Its responsibilities include:

*   Constructing prompts for LLM interactions.
*   Handling API calls to OpenAI.
*   Processing and manipulating text, including diff generation.
*   Loading and managing configuration settings from `.env` files.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Python 3**: The scripts are written in Python 3.
- **Dependencies**: The necessary Python packages are listed in `requirements.txt`. These can be installed using `pip` (see Configuration section).
- **OpenAI API Key**: An OpenAI API key is required for LLM-based feedback. This needs to be set as an environment variable (see Configuration section).
- **clang-tidy**: For C code analysis with `generate_feedback_single.py`, `clang-tidy` must be installed and accessible in your system's PATH.

## Configuration

This section details how to set up dependencies and environment variables.

1.  **Install Dependencies**:
    Open your terminal and run:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Environment Variables**:
    API keys, file paths, and LLM model names are configured via environment variables, typically loaded from `.env` files.

    *   `config_repo.env`: Used by `generate_feedback_repo.py`.
    *   `config_single.env`: Used by `generate_feedback_single.py`.

    **Managing Configuration Files**:
    *   **Copy and Edit**: It's best to copy these template files (e.g., to `my_config_repo.env`) and edit your copy.
    *   **Rename**: Alternatively, rename your chosen config file (e.g., `my_config_repo.env`) to `.env` in the root directory before running a script.
    *   **Security**: **Do not commit your API keys**. If you copy/rename, add your specific config file (e.g., `my_config_repo.env` or `.env`) to your `.gitignore`.
    *   **Advanced**: Tools like `direnv` or the `python-dotenv` CLI can also be used to manage loading of `.env` files for more complex workflows.

    **Key Environment Variables**:

    *   `OPENAI_API_KEY`: Your OpenAI API key.
    *   `PROBLEM_STATEMENT`: Path to the assignment's problem description file.
    *   `RUBRIC`: Path to the grading rubric or code quality guidelines file.
    *   `PROPOSER_REVIEWER`: OpenAI model ID for Proposer/Reviewer LLMs (e.g., `gpt-4`, `gpt-3.5-turbo`).
    *   `SUMMARIZER`: OpenAI model ID for summarizing feedback (used by `generate_feedback_single.py`) (e.g., `gpt-3.5-turbo`).

## Usage

Ensure your environment variables are configured as described above before running the scripts.

### `generate_feedback_repo.py`

Compares a submission repository against a source/template repository.

**Command:**
```bash
python generate_feedback_repo.py <path_to_source_repo> <path_to_target_repo>
```
**Placeholders:**
*   `<path_to_source_repo>`: Path to the original/template repository (e.g., `input/xv6-public`).
*   `<path_to_target_repo>`: Path to the student's submission repository (e.g., `input/threads-in-xv6-submission`).

### `generate_feedback_single.py`

Analyzes a single program file, optionally using `clang-tidy`.

**Command:**
```bash
python generate_feedback_single.py <path_to_program_file>
```
**Placeholders:**
*   `<path_to_program_file>`: Path to the student's program file (e.g., `input/example_submission.c`).

## Output

Feedback is saved in the `output/` directory, typically mirroring the input's naming or structure, often within a timestamped subdirectory.

### For `generate_feedback_repo.py`

*   **Location**: e.g., `output/threads-in-xv6-submission_feedback/<timestamp>/`.
*   **Format**: A single feedback file (e.g., `feedback.c`, `feedback.py`) containing code from processed files with inline LLM comments. Unchanged/unselected files may be excluded.

### For `generate_feedback_single.py`

*   **Location**: e.g., `output/example_submission_feedback/<timestamp>/`.
*   **Format**: A file named `<original_filename>_feedback.<ext>` (e.g., `example_submission_feedback.c`) with:
    *   Original code.
    *   Inline LLM comments.
    *   A summary section at the end (including `clang-tidy` diagnostics if applicable).

## Contributing

Contributions are welcome!

*   **Open an Issue**: For major changes or bugs, please open an issue first for discussion.
*   **Fork and Pull Request**: Fork the repo, make changes in a branch, and submit a pull request. Ensure your code is documented.

We appreciate your help!

## License

A `LICENSE` file is important for open-source projects. Currently, one is not present.

We recommend adding a `LICENSE` file. If source headers mention a license, ensure the file is included. Common choices are MIT or Apache License 2.0, but the `LICENSE` file is definitive.
