Advent of Code 2019 in C
========================

Solutions in C to the puzzles of [Advent of Code
2019](https://adventofcode.com/2019).

Commands
--------

-   `make` to build all executables
-   `make run` to run all solvers
-   `make <day>` (e.g. `make 1`) to run the program solving the puzzle
    of the specified day
-   `make test` to run all tests
-   `make time` to run all solvers and print timings
-   `make clean` to remove all files generated by `make`

In addition, `debug=1` and/or `CC=<compiler>` can be used as arguments
to `make`. For example, `make clean; make debug=1 CC=clang test` will
run all tests after building all solvers using
[clang](https://clang.llvm.org/) with additional warnings and flags for
debugging. By default, compilation is done with
[gcc](https://gcc.gnu.org/).
