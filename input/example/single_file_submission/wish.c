#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

#define MAX_ARGS 64       // Max arguments per command
#define MAX_PATHS 64      // Max paths in search path
#define MAX_COMMANDS 64   // Max parallel commands

char *paths[MAX_PATHS];
int path_count = 0;

void change_directory(char **args) {
    if (args[1] == NULL || args[2] != NULL) {
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
    char cleaned[1024];
    int i = 0, j = 0;
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
    strcpy(input, cleaned);
}

int split_input(char *input, char **args, char **output_file) {
    int argc = 0;
    char *token;
    int redirect_found = 0;
    int no_more_args = 0;

    clean_input(input);

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
