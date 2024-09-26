#!/bin/bash

# Configuration

PROGRAM=spellcheck
EXECUTABLE=./$PROGRAM
WORKSPACE=/tmp/$PROGRAM.$(id -u)
POINTS=5
FAILURES=0

# Functions

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && cat $WORKSPACE/test
    echo
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

# Test Cases

output_quotes() {
    cat <<EOF
blessings
endowed
fortunes
insure
mutually
ordain
posterity
tranquility
truths
unalienable
EOF
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $PROGRAM ..."

# head -n 100 norvig_smaller.txt > $WORKSPACE/tiny.txt
# ./$EXECUTABLE norvig_count_1w.txt norvig_smaller.txt > $WORKSPACE/uncommon
./$EXECUTABLE common_10k.txt quotes.txt > $WORKSPACE/uncommon

printf " %-40s ... " "quotes (output)"
diff -w -y <(cat $WORKSPACE/uncommon) <(output_quotes) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

# This is searching for the number of occurrences of "Success" in this script itself
TESTS=$(($(grep -c Success $0) - 2))

echo
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * $POINTS.0" | bc | awk '{ printf "%0.2f\n", $1 }' ) / $POINTS.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
