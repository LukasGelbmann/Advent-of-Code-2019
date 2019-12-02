# Tools to enable integration testing.

set -o nounset


_NEWLINE='
'
_CARRIAGE_RETURN=$(printf '\r')
_RED='\033[1;31m'
_GREEN='\033[1;32m'
_END_COLOR='\033[0m'

_REAL_PATH="$(readlink -f -- "$0" 2>/dev/null)" || _REAL_PATH="$0"
_BASE_NAME="$(basename -- "$_REAL_PATH")" || return $?
_LABEL="${_BASE_NAME%.sh}"
_PROGRAM_PATH=$(echo "${_LABEL}"*.c) || return $?
_BIN_PATH="bin/${_PROGRAM_PATH%.c}"

_passed=0
_failed=0


# Print a summary and return 0 (success) if we passed the test suite.
summarize() {(
    _passed_all
    passed_all_ret=$?

    if [ -t 1 ]; then
        if [ "$passed_all_ret" = 0 ]; then
            color="$_GREEN"
        else
            color="$_RED"
        fi
        end="$_END_COLOR"
    else
        color=''
        end=''
    fi

    if [ "$passed_all_ret" != 0 ]; then
        if [ "$_passed" -eq 1 ]; then
            ending=''
        else
            ending='s'
        fi
        message="Passed ${_passed} test${ending} and failed ${_failed}."
    elif [ "$_passed" -eq 1 ]; then
        message="Passed 1 test (the only one)."
    else
        message="Passed all ${_passed} tests."
    fi
    printf "$color%s: %s$end\n" "$_LABEL" "$message"
    return "$passed_all_ret"
)}

# Return 0 (success) if we passed at least one test and failed none.
_passed_all() {
    [ "$_passed" -gt 0 ] && [ "$_failed" -eq 0 ]
}

# Run a test that checks the output lines.
test_output() {
    _check_output "$@"
    _count_test $?
}

# Run a command and return 0 (success) if the output lines are as expected.
_check_output() {(
    if [ "$1" = 'empty' ]; then
        filename="</dev/null"
    else
        filename="test/data/${_LABEL}_$1.txt"
    fi
    command="$_BIN_PATH $filename"
    shift 1

    output_dot=$(sh -c "$command"; ret=$?; echo .; exit "$ret")
    ret=$?
    if [ "$ret" != 0 ]; then
        _print_failure "got exit code $ret" "$filename"
        return 1
    fi
    output=${output_dot%.}

    line_no=1
    for expected do
        if [ -z "$output" ]; then
            if [ "$line_no" = 1 ]; then
                _print_failure "no output" "$filename"
            else
                diagnostic="missing output from line $line_no"
                _print_failure "$diagnostic" "$filename"
            fi
            return 1
        fi

        line=${output%%$_NEWLINE*}
        case "$output" in
        *"$_NEWLINE"*)
            # Under Windows, a carriage return may have been printed.
            line=${line%$_CARRIAGE_RETURN}
            missing_newline=''
            ;;
        *)
            missing_newline='yes'
            ;;
        esac

        if [ "$line" != "$expected" ]; then
            diagnostic="expected \"$expected\""
            if [ $# -gt 1 ]; then
                diagnostic="$diagnostic in line $line_no"
            fi
            diagnostic="$diagnostic, got \"$line\""
            _print_failure "$diagnostic" "$filename"
            return 1
        fi
        if [ "$missing_newline" ]; then
            _print_failure "missing newline" "$filename"
            return 1
        fi

        output=${output#*$_NEWLINE}
        line_no=$((line_no + 1))
    done

    if [ "$output" ]; then
        _print_failure "too many output lines" "$filename"
        return 1
    fi

    return 0
)}

# Update the counters of passed and failed tests.
_count_test() {
    if [ "$1" = 0 ]; then
        _passed=$((_passed + 1))
    else
        _failed=$((_failed + 1))
    fi
}

# Print a message describing a failed test.
_print_failure() {(
    diagnostic="$1"
    message="$2"
    printf "[%s] Failed test (%s): %s\n" "$_LABEL" "$diagnostic" "$message"
)}
