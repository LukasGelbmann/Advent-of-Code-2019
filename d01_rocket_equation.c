// Day 1: The Tyranny of the Rocket Equation

#include "errors.h"
#include "io.h"

#include <stdio.h>
#include <stdlib.h>


// Return the fuel required for some mass, including fuel needed to lift fuel.
static long recursive_fuel(long mass)
{
    long fuel = 0;
    while ((mass = mass / 3 - 2) > 0) {
        fuel += mass;
    }
    return fuel;
}

// Print the answer to both parts, reallocating the buffer if needed.
static error solve_with_buffer(FILE *in, char **buffer_ptr, size_t *size_ptr)
{
    error err;
    long total_simple = 0;
    long total_recursive = 0;
    while (!(err = read_stripped_line(buffer_ptr, size_ptr, in))) {
        long mass;
        err = parse_long(&mass, *buffer_ptr);
        if (err) {
            return err;
        }
        total_simple += mass / 3 - 2;
        total_recursive += recursive_fuel(mass);
    }
    if (err != ERR_EOF) {
        return err;
    }
    printf("%ld\n", total_simple);
    printf("%ld\n", total_recursive);
    return SUCCESS;
}

// Print the answer to both parts of the puzzle.
static error solve(FILE *in)
{
    char *buffer = NULL;
    size_t buffer_size = 0;
    error err = solve_with_buffer(in, &buffer, &buffer_size);
    free(buffer);
    return err;
}

// For each input file, print the answer to both parts of the puzzle.
int main(int argc, char *const argv[])
{
    return solve_all(solve, argc, argv);
}
