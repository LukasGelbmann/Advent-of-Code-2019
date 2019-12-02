#ifndef IO_H
#define IO_H

// This header defines tools related to input and output.

#include "errors.h"

#include <stdbool.h>
#include <stdio.h>


// Print the solutions for all given input files and return an exit code.
//
// If no names of input files have been passed in as command-line arguments,
// use the default input file.
//
int solve_all(error solve(FILE *in), int argc, char *const argv[]);

// Convert a string representing an integer to long.
error parse_long(long *value_ptr, const char *str);

// Read a line into a buffer.
//
// Input is read from the stream `in` until either a newline character is
// encountered, the end of the file is reached, or an error occurs.  No
// additional characters are read after this point.  On success, the buffer is
// null-terminated and does not include the terminating newline character, if
// there was one.  The buffer contents after the terminating null byte are
// indeterminate.
//
// Before calling read_stripped_line(), `*buffer_ptr` can be NULL or a pointer
// to a buffer allocated by a malloc-family function.  In the latter case, the
// buffer must be able to hold `*size_ptr` bytes.
//
// After a call to read_stripped_line(), `*buffer_ptr` may have been changed to
// point to a new buffer allocated by a malloc-family function.  In this case,
// the size of the buffer is stored in `*size_ptr` and the buffer should be
// freed by the caller.
//
// If the end of the file is reached during a call to read_stripped_line(), the
// end-of-file indicator of `in` is set.  If this happens before any characters
// have been read, the return value indicates an error.  In this case, the
// contents of the buffer remain unchanged in the first `*size_ptr` bytes, for
// the initial value of `*size_ptr`, and any other buffer contents are
// indeterminate.  If, on the other hand, the end of the file is reached after
// at least one character has been read, the return value is SUCCESS.
//
// If an error occurs while attempting to read from `in`, the return value
// indicates an error and the contents of the buffer are indeterminate.
//
// read_stripped_line() does not give special treatment to null bytes read from
// the stream.  Note, however, that it is generally impossible for the caller
// to tell the difference between a null byte read from the stream and the
// terminating null byte.
//
error read_stripped_line(char **buffer_ptr, size_t *size_ptr, FILE *in);

#endif
