#!/bin/sh --

REAL_PATH="$(readlink -f -- "$0" 2>/dev/null)" || REAL_PATH="$0"
TEST_PATH="$(dirname -- "$REAL_PATH")" || exit $?

cd -- "$TEST_PATH/.." || exit $?
. test/testing.sh || exit $?


main() {
    test_output 1 10484582397840 15726873581717
    test_output 2 3103673258794604431 4655509888191850124
    test_output empty 0 0
    summarize
}

main
