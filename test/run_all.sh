#!/bin/sh --

# This script runs all tests and returns 0 (success) if we pass them all.

real_path="$(readlink -f -- "$0" 2>/dev/null)" || real_path="$0"
test_path="$(dirname -- "$real_path")" || exit

retval=0
for script_filename in "$test_path"/d[0-9][0-9].sh; do
    sh "$script_filename" || retval=1
done
exit "$retval"
