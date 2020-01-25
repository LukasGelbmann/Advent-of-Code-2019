#!/bin/sh --

# This script runs puzzle solvers.

set -o nounset

_BLUE='\033[34;1m'
_END_COLOR='\033[0m'

# Print a string indicating which command to use for timings.
time_mode() {
    if env time --format="(%es)" true >/dev/null 2>&1; then
        echo 'env-time'
    elif (time -p true) >/dev/null 2>&1; then
        echo 'time-p'
    else
        echo 'time'
    fi
}

# Print the solution to a puzzle.
solve() { (
    label="$1"
    mode="$2"
    source_filename="$3"

    bin="bin/${source_filename%.c}"
    input="input/${label}.txt"

    if [ "$mode" = 'env-time' ]; then
        env time --format="(%es)" "$bin" "$input"
    elif [ "$mode" = 'time-p' ]; then
        time -p "$bin" "$input"
    elif [ "$mode" = 'time' ]; then
        time "$bin" "$input"
    else
        "$bin" "$input"
    fi
); }

# Solve one puzzle if a day is given as an argument, else solve them all.
#
# If 'time' is given as an argument, print timings.
#
main() {
    real_path="$(readlink -f -- "$0" 2>/dev/null)" || real_path="$0"
    base_path="$(dirname -- "$real_path")" || return
    cd -- "$base_path" || return

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

    if [ "$day" ]; then
        if ! label="$(printf 'd%02d' "$day")" 2>/dev/null; then
            printf "Error: can't use day '%s' as integer\n" "$day" >&2
            return 1
        fi

        solve "$label" "$mode" "$label"_*.c
        return
    fi

    if [ -t 1 ]; then
        heading="$_BLUE"
        end_heading="$_END_COLOR"
    else
        heading=''
        end_heading=''
    fi

    for source_filename in d[0-9][0-9]_*.c; do
        label="${source_filename%%_*}"
        day="${label#d}"
        day="${day#0}"

        printf "${heading}# Day %d #${end_heading}\n" "$day"
        solve "$label" "$mode" "$source_filename"
        ret=$?
        echo

        if [ "$ret" != 0 ]; then
            return "$ret"
        fi
    done

    return 0
}

main "$@"
