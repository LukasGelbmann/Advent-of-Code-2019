// Day 1: The Tyranny of the Rocket Equation

#include "errors.h"
#include "io.h"

#include <stdio.h>


// Return the fuel required for some mass, including fuel needed to lift fuel.
static long recursive_fuel(long mass)
{
    long fuel = 0;
    while ((mass = mass / 3 - 2) > 0) {
        fuel += mass;
    }
    return fuel;
}

// Print the answer to both parts.
static error solve(FILE *in)
{
    error err;
    char *buffer = NULL;
    size_t buffer_size = 0;

    long total_simple = 0;
    long total_recursive = 0;
    while ((err = read_stripped_line(&buffer, &buffer_size, in)) != ERR_EOF) {
        if (err) {
            return err;
        }
        long mass;
        err = parse_long(&mass, buffer);
        if (err) {
            return err;
        }
        total_simple += mass / 3 - 2;
        total_recursive += recursive_fuel(mass);
    }
    printf("%ld\n", total_simple);
    printf("%ld\n", total_recursive);

    return SUCCESS;
}

// For each input file, print the answer to both parts of the puzzle.
int main(int argc, char *const argv[])
{
    return solve_all(solve, argc, argv);
}
