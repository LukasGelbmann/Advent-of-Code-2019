#!/bin/sh --

real_path="$(readlink -f -- "$0" 2>/dev/null)" || real_path="$0"
test_path="$(dirname -- "$real_path")" || exit
cd -- "$test_path/.." || exit
. test/testing.sh || exit

test_output 1 10484582397840 15726873581717
test_output 2 3103673258794604431 4655509888191850124
test_output empty 0 0
summarize
