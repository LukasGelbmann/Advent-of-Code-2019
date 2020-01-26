#ifndef ERRORS_H
#define ERRORS_H

// This header defines errors and tools related to them.


// An error gives an indication as to what went wrong.
typedef enum {
    SUCCESS,

    // Parsing errors
    ERR_PARSE_INT_INVALID,
    ERR_PARSE_INT_OVERFLOW,

    // Memory-related errors
    ERR_OUT_OF_MEMORY,
    ERR_REALLOC,

    // File-related errors
    ERR_OPEN,
    ERR_CLOSE,
    ERR_READ,
    ERR_EOF,
} error;


// Print an error message to stderr.
void print_error(error err);

#endif
