#include "io.h"

#include "errors.h"

#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


// The size given to a new buffer by default.
static const size_t default_buffer_size = 120;


// Print the solutions for an input file.
static error solve_for_file(error solve(FILE *in), const char *filename)
{
    FILE *in = fopen(filename, "r");
    if (in == NULL) {
        return ERR_OPEN;
    }

    error err = solve(in);
    if (fclose(in) != 0 && !err) {
        err = ERR_CLOSE;
    }
    return err;
}

int solve_all(error solve(FILE *in), int argc, char *const argv[])
{
    int exit_code = EXIT_SUCCESS;
    if (argc <= 1) {
        error err = solve(stdin);
        if (err) {
            print_error(err);
            exit_code = EXIT_FAILURE;
        }
    }
    for (int i = 1; i < argc; i++) {
        error err = solve_for_file(solve, argv[i]);
        if (err) {
            print_error(err);
            exit_code = EXIT_FAILURE;
        }
    }
    return exit_code;
}

error parse_long(long *value_ptr, const char *str)
{
    char *end;
    errno = 0;
    *value_ptr = strtol(str, &end, 10);
    if (errno == ERANGE) {
        return ERR_PARSE_INT_OVERFLOW;
    }
    if (end == str || *end != '\0') {
        return ERR_PARSE_INT_INVALID;
    }
    return SUCCESS;
}

error read_stripped_line(char **buffer_ptr, size_t *size_ptr, FILE *in)
{
    size_t read = 0;
    for (;;) {
        if (*buffer_ptr == NULL || *size_ptr <= read + 1) {
            size_t new_size;
            if (*buffer_ptr == NULL || *size_ptr <= default_buffer_size / 2) {
                new_size = default_buffer_size;
            } else if (*size_ptr < SIZE_MAX / 2) {
                new_size = 2 * *size_ptr;
            } else if (*size_ptr < SIZE_MAX) {
                new_size = SIZE_MAX;
            } else {
                return ERR_OUT_OF_MEMORY;
            }

            char *new_buffer = realloc(*buffer_ptr, new_size);
            if (new_buffer == NULL) {
                return ERR_REALLOC;
            }
            *buffer_ptr = new_buffer;
            *size_ptr = new_size;
        }

        char *chunk = *buffer_ptr + read;
        size_t chunk_size = *size_ptr - read;
        if (chunk_size > INT_MAX) {
            chunk_size = INT_MAX;
        }
        assert(chunk_size > 1);

        if (fgets(chunk, (int)chunk_size, in) == NULL) {
            if (!feof(in)) {
                return ERR_READ;
            }
            if (read == 0) {
                return ERR_EOF;
            }
            return SUCCESS;
        }

        if (feof(in)) {
            return SUCCESS;
        }

        // At this point, we know that fgets() has either read a newline or
        // read (chunk_size - 1) bytes from the stream, possibly including null
        // bytes.
        for (size_t i = 0; i < chunk_size - 1; i++) {
            if (chunk[i] == '\n') {
                chunk[i] = '\0';
                return SUCCESS;
            }
        }
        read += chunk_size - 1;
    }
}
