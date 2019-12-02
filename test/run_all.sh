#!/bin/sh --

# This script runs all tests and returns 0 (success) if we pass them all.


REAL_PATH="$(readlink -f -- "$0" 2>/dev/null)" || REAL_PATH="$0"
TEST_PATH="$(dirname -- "$REAL_PATH")" || exit $?


main() {
    cd -- "$TEST_PATH" || return $?

    retval=0
    for script_filename in d[0-9][0-9].sh; do
        sh "$script_filename" || retval=1
    done
    return "$retval"
}

main
