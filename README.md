# code-critique

This tool provides automated feedback on code quality for programming assignments. It works for single-file program submissions as well as assignments that build on top of existing code repository.

Blog Post: [https://pankajpansari.github.io/posts/code-critique/](https://pankajpansari.github.io/posts/code-critique/)

## Core Scripts

### `generate_feedback_repo.py`

For assignments that involve addition and modifications to multiple files from an existing source repo. Works with diffs between source and target repositories.

### `generate_feedback_single.py`

For single-file programming assignments. Integrates output from linter `clang-tidy` to offer more accurate feedback. 

## Utility Module

### `feedback_utils.py`

Contains shared utility functions, data models and prompt templates. 

## Prerequisites

- **Python3** 
- **OpenAI API Key**: Set in your .env file. 
- **clang-tidy**: For C code analysis

## Configuration

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Environment Variables**:
    API keys, file paths, and LLM model names are configured via environment variables, typically loaded from `.env` files.

    *   `config_repo.env`: Used by `generate_feedback_repo.py`.
    *   `config_single.env`: Used by `generate_feedback_single.py`.

    **Key Environment Variables**:

    *   `OPENAI_API_KEY`: Your OpenAI API key.
    *   `PROBLEM_STATEMENT`: Path to the assignment's problem description file.
    *   `RUBRIC`: Path to the grading rubric or code quality guidelines file.
    *   `PROPOSER_REVIEWER`: OpenAI model string for Proposer/Reviewer LLMs
    *   `SUMMARIZER`: OpenAI model string for LLM that summarizes linter output and overall feedback

## Usage

Ensure your environment variables are configured as described above before running the scripts.

### Repository Submission 

Compares a submission (target) repository against a source repository.

**Command:**
```bash
python3 generate_feedback_repo.py input/example/repo_submission/source_repo input/example/repo_submission/target_repo
```

### Single-file Submission 

Analyzes a single program file; calls `clang-tidy` internally.

**Command:**
```bash
python3 generate_feedback_single.py input/example/single_file_submission/wish.c
```
## Output

Feedback is saved in the `output/` directory, mirroring the input's naming or structure.

### For `generate_feedback_repo.py`

A single feedback file (e.g., `feedback.c`, `feedback.py`) containing code from processed files with inline LLM comments. Unchanged/unselected files may be excluded. 

Sample output in this [gist](https://gist.github.com/pankajpansari/9daa8eee121fe84ad1401fd99591e184)

### For `generate_feedback_single.py`

A single file named with original code, inline LLM comments and a summary section at the end.
    
Sample output in this [gist](https://gist.github.com/pankajpansari/909e9aa46643d474c1393ac154da1a7b)

# Limitations

While I've had encouraging feedback from students who received evaluation from this tool, a thorough testing on the precision/recall of feedback comments is still in progress.

**code-critique** does not provide feedback on design and refactoring of programs spread over multiple files, considering them in unison. 

Prompt caching for the current implementation is sub-optimal. If running on a big batch of submission, I can help you with more efficient prompt caching. 

Structured output functionality (currently provided by OpenAI and Google Gemini) is needed. 

Linter was not used for repo submission for my use-case, but can be easily incorporated.

Feedback welcome at `pankaj dot pansari at proton.me`

# Acknowledgments

The rubric for code quality evaluation was borrowed from Stanford course CS107 - Computer Organizations and Systems. 

Thanks to Gaurav Agrawal, Nikhil Henry for the helpful feedback (list in progress.)

# License

This project is licensed under the MIT License - see the LICENSE file for details.