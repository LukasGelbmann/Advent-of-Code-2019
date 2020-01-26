#include "errors.h"

#include <stdio.h>


// Return an error message.
static const char *error_message(error err)
{
    switch (err) {
    case SUCCESS:
        return "success";
    case ERR_PARSE_INT_INVALID:
        return "can't parse integer (invalid argument)";
    case ERR_PARSE_INT_OVERFLOW:
        return "can't parse integer (outside valid range)";
    case ERR_OUT_OF_MEMORY:
        return "out of memory";
    case ERR_REALLOC:
        return "failed to reallocate memory";
    case ERR_OPEN:
        return "can't open file";
    case ERR_CLOSE:
        return "can't close file";
    case ERR_READ:
        return "can't read from file";
    case ERR_EOF:
        return "reached end of file";
    default:
        return "unknown error";
    }
}

void print_error(error err)
{
    if (err == SUCCESS) {
        fputs("No error\n", stderr);
    }
    fprintf(stderr, "Error: %s\n", error_message(err));
}
