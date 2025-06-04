#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

#define MAX_ARGS 64       // Max arguments per command
#define MAX_PATHS 64      // Max paths in search path
#define MAX_COMMANDS 64   // Max parallel commands


/* 
 * REVIEW: `paths` and `path_count` are declared as globals, which increases coupling and 
 * hinders testing. Consider encapsulating shell state in a struct passed to 
 * functions, or at minimum mark these variables `static` to limit their linkage.
 */
char *paths[MAX_PATHS];
int path_count = 0;

void change_directory(char **args) {
    if (args[1] == NULL || args[2] != NULL) {

/* 
 * REVIEW: The literal length `22` is repeated in each `write` call for the error message. 
 * Define a single `const char error_message[] = "An error has occurred\n";` and 
 * use `sizeof error_message` to avoid mismatches and improve maintainability.
 */
        write(STDERR_FILENO, "An error has occurred\n", 22);
        return;
    }
    if (chdir(args[1]) != 0) {
        write(STDERR_FILENO, "An error has occurred\n", 22);
    }
}

void update_path(char **args) {
    for (int i = 0; i < path_count; i++) {
        free(paths[i]);
    }
    path_count = 0;

    int i = 1;
    while (args[i] != NULL && path_count < MAX_PATHS) {
        paths[path_count] = strdup(args[i]);
        path_count++;
        i++;
    }
}

int run_command(char **args) {
    if (path_count == 0) {
        write(STDERR_FILENO, "An error has occurred\n", 22);
        return -1;
    }

    for (int i = 0; i < path_count; i++) {

/* 
 * REVIEW: Using a fixed 256-byte buffer for `full_path` can overflow if the directory plus 
 * command name exceeds this length. Consider using `PATH_MAX` or dynamically 
 * allocating exactly the needed size.
 */
        char full_path[256];
        snprintf(full_path, sizeof(full_path), "%s/%s", paths[i], args[0]);

        if (access(full_path, X_OK) == 0) {
            execv(full_path, args);
            return -1;
        }
    }

    write(STDERR_FILENO, "An error has occurred\n", 22);
    return -1;
}

void clean_input(char *input) {

/* 
 * REVIEW: The local buffer `cleaned[1024]` can overflow if `input` exceeds 1023 
 * characters. Since `getline` may return arbitrarily long lines, either 
 * dynamically size `cleaned` or enforce a bounds check before writing into it.
 */
    char cleaned[1024];
    int i = 0, j = 0;

/* 
 * REVIEW: You assign `strlen(input)` (a `size_t`) to an `int len`. This narrowing 
 * conversion can overflow on large inputs. Use `size_t` for `len` to match the 
 * return type of `strlen`.
 */
    int len = strlen(input);

    while (i < len) {
        if (input[i] == '>' || input[i] == '&') {
            if (j > 0 && cleaned[j - 1] != ' ') {
                cleaned[j++] = ' ';
            }
            cleaned[j++] = input[i];
            if (i + 1 < len && input[i + 1] != ' ') {
                cleaned[j++] = ' ';
            }
        } else {
            cleaned[j++] = input[i];
        }
        i++;
    }
    cleaned[j] = '\0';

/* 
 * REVIEW: `strcpy(input, cleaned)` is unbounded and risks buffer overflows. Use a bounded 
 * copy such as `strlcpy` (if available) or `snprintf` to ensure you don’t exceed 
 * `input`’s allocated size.
 */
    strcpy(input, cleaned);
}

int split_input(char *input, char **args, char **output_file) {
    int argc = 0;
    char *token;
    int redirect_found = 0;
    int no_more_args = 0;

    clean_input(input);


/* 
 * REVIEW: `strsep(&input, ...)` modifies the `input` pointer itself, which can make later 
 * debugging harder and might surprise readers. Consider working on a duplicate 
 * pointer or using `strtok_r` if you need to preserve the original buffer.
 */
    while ((token = strsep(&input, " \t\n")) != NULL) {
        if (strlen(token) == 0) {
            continue;
        }

        if (no_more_args) {
            write(STDERR_FILENO, "An error has occurred\n", 22);
            return -1;
        }

        if (strcmp(token, ">") == 0) {
            if (redirect_found || argc == 0) {
                write(STDERR_FILENO, "An error has occurred\n", 22);
                return -1;
            }
            redirect_found = 1;
        } else if (redirect_found) {
            *output_file = token;
            redirect_found = 0;
            no_more_args = 1;
        } else {
            args[argc++] = token;
        }
    }

    if (redirect_found) {
        write(STDERR_FILENO, "An error has occurred\n", 22);
        return -1;
    }

    args[argc] = NULL;
    return argc;
}

void execute_command(char *command) {
    char *args[MAX_ARGS];
    char *output_file = NULL;

    int argc = split_input(command, args, &output_file);

    if (argc == -1 || argc == 0) {
        return;
    }

    if (strcmp(args[0], "exit") == 0) {
        if (argc > 1) {
            write(STDERR_FILENO, "An error has occurred\n", 22);
        } else {
            exit(0);
        }
    } else if (strcmp(args[0], "cd") == 0) {
        change_directory(args);
    } else if (strcmp(args[0], "path") == 0) {
        update_path(args);
    } else {
        pid_t pid = fork();
        if (pid == 0) {
            if (output_file != NULL) {

/* 
 * REVIEW: The file-creation mode `0644` is a magic constant. Define a macro or constant 
 * like `#define OUTPUT_MODE 0644` to document its meaning and avoid repetition.
 */
                int fd = open(output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
                if (fd < 0) {
                    write(STDERR_FILENO, "An error has occurred\n", 22);
                    exit(1);
                }
                dup2(fd, STDOUT_FILENO);
                dup2(fd, STDERR_FILENO);
                close(fd);
            }
            if (run_command(args) == -1) {
                exit(1);
            }
        } else if (pid > 0) {
            wait(NULL);
        } else {
            write(STDERR_FILENO, "An error has occurred\n", 22);
        }
    }
}


/* 
 * REVIEW: `main` handles initialization, the prompt loop, parsing, execution, and cleanup, 
 * giving it high cognitive complexity. Break it into smaller functions (e.g., 
 * `run_interactive()`, `run_batch()`, `cleanup()`) to improve readability and 
 * testability.
 */
int main(int argc, char **argv) {
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    FILE *input_file = stdin;

    paths[path_count++] = strdup("/bin");

    if (argc == 2) {
        input_file = fopen(argv[1], "r");
        if (input_file == NULL) {
            write(STDERR_FILENO, "An error has occurred\n", 22);
            exit(1);
        }
    } else if (argc > 2) {
        write(STDERR_FILENO, "An error has occurred\n", 22);
        exit(1);
    }

    while (1) {
        char *commands[MAX_COMMANDS];
        int command_count = 0;

        if (input_file == stdin) {
            printf("wish> ");
            fflush(stdout);
        }

        read = getline(&line, &len, input_file);
        if (read == -1) {
            break;
        }

        clean_input(line);

        int contains_ampersand = 0;
        for (int i = 0; line[i] != '\0'; i++) {
            if (line[i] == '&') {
                contains_ampersand = 1;
                break;
            }
        }

        if (contains_ampersand) {
            char *token;
            while ((token = strsep(&line, "&")) != NULL) {
                if (strlen(token) > 0) {
                    commands[command_count++] = strdup(token);
                }
            }

            pid_t pids[MAX_COMMANDS];
            for (int i = 0; i < command_count; i++) {
                pid_t pid = fork();
                if (pid == 0) {
                    execute_command(commands[i]);
                    exit(0);
                } else if (pid > 0) {
                    pids[i] = pid;
                } else {
                    write(STDERR_FILENO, "An error has occurred\n", 22);
                }
            }

            for (int i = 0; i < command_count; i++) {
                waitpid(pids[i], NULL, 0);
            }

            for (int i = 0; i < command_count; i++) {
                free(commands[i]);
            }
        } else {
            execute_command(line);
        }
    }

    for (int i = 0; i < path_count; i++) {
        free(paths[i]);
    }
    if (input_file != stdin) {
        fclose(input_file);
    }
    free(line);
    return 0;
}

/*
 *
 * STRENGTHS: 
 *The implementation cleanly separates built-in commands (`exit`, `cd`, `path`), 
 * parsing, and execution; correctly uses `fork`/`execv`; handles I/O redirection 
 * with `dup2`; supports parallel commands; frees dynamic memory; and maintains 
 * consistent indentation and naming conventions with appropriate standard library 
 * calls.
 *
 * AREAS FOR IMPROVEMENT: 
 *Eliminate or guard fixed-size buffers (`full_path`, `cleaned`) to prevent 
 * overflows; replace unsafe APIs (`strcpy`) and magic literals (`22`, `256`, 
 * `1024`, `0644`) with named constants; encapsulate global state; check return 
 * values of `snprintf`, `fflush`, `fclose`; reduce duplication in error handling 
 * and fork/wait logic; and decompose large functions into smaller, focused units.
 *
 * OVERALL ASSESSMENT: 
 *A solid, functional shell implementation covering the required features. 
 * Addressing buffer-safety issues, magic numbers, and refactoring for modularity 
 * will enhance robustness and maintainability.
*/