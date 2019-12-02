#!/bin/sh --

# This script runs puzzle solvers.

set -o nounset


REAL_PATH="$(readlink -f -- "$0" 2>/dev/null)" || REAL_PATH="$0"
BASE_PATH="$(dirname -- "$REAL_PATH")" || exit $?


# Print the path to a puzzle solving executable.
bin_path() {(
    source_path="$1"
    stem=${source_path%.c}
    printf "bin/%s" "$stem"
)}

# Print the path to an input file.
input_path() {(
    label="$1"
    printf "input/%s.txt" "$label"
)}

# Print a string indicating which command to use for timings.
time_mode() {(
    if env time --format="" true >/dev/null 2>&1; then
        echo 'env-time'
    elif (time -p true) >/dev/null 2>&1; then
        echo 'time-p'
    else
        echo 'time'
    fi
)}

# Print the solution to a puzzle.
solve() {(
    bin="$1"
    input="$2"
    mode="$3"
    day="$4"

    if [ "$day" ]; then
        echo "# Day $day #"
    fi

    if [ "$mode" = 'env-time' ]; then
        env time --format="(%es)" "$bin" "$input"
    elif [ "$mode" = 'time-p' ]; then
        time -p "$bin" "$input"
    elif [ "$mode" = 'time' ]; then
        time "$bin" "$input"
    else
        "$bin" "$input"
    fi
)}

# Solve one puzzle if a day is given as an argument, else solve them all.
#
# If 'time' is given as an argument, print timings.
#
main() {
    if [ "${1-}" = "time" ]; then
        day="${2-}"
    else
        day="${1-}"
    fi

    if [ "${1-}" = "time" ] || [ "${2-}" = "time" ]; then
        mode="$(time_mode)"
    else
        mode='none'
    fi

    cd -- "$BASE_PATH" || return $?

    if [ "$day" ]; then
        if ! label=$(printf 'd%02d' "$day") 2>/dev/null; then
            printf "Error: can't use day '%s' as integer\n" "$day"
            return 1
        fi
        source_path=$(echo "$label"*.c)
        bin="$(bin_path "$source_path")"
        if [ ! -e "$bin" ]; then
            printf "Error: executable '%s' doesn't exist\n" "$bin"
            return 1
        fi
        solve "$bin" "$(input_path "$label")" "$mode" ''
        return $?
    fi

    for source_path in d[0-9][0-9]*.c; do
        label="${source_path%%_*}"
        day="${label#d}"
        day="${day#0}"

        bin="$(bin_path "$source_path")"
        input="$(input_path "$label")"

        solve "$bin" "$(input_path "$label")" "$mode" "$day"
        ret=$?
        echo

        if [ "$ret" != 0 ]; then
            return "$ret"
        fi
    done
}

main "$@"
