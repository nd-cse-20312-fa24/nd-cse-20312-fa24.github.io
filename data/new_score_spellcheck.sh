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

output_head() {
    cat <<EOF
abettors
acetones
adamses
aggravatedly
alleghanies
amorys
apparelled
aproned
arat
arnsworth
EOF
}

output_tail() {
    cat <<EOF
weightiest
westhouse
westphail
whipcord
whishing
wiberd
willings
windibank
windigate
woolseys
EOF
}

output_wc() {
    cat <<EOF
221     221    2149
EOF
}

output_tiny() {
    cat <<EOF
eglonitz
eglow
egria
gasogene
iodoform
slavey
trepoff
uncourteous
EOF
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $PROGRAM ..."

head -n 100 norvig_smaller.txt > $WORKSPACE/tiny.txt
# ./$EXECUTABLE norvig_count_1w.txt norvig_smaller.txt > $WORKSPACE/uncommon
./$EXECUTABLE norvig_count_1w.txt $WORKSPACE/tiny.txt > $WORKSPACE/uncommon

# printf " %-40s ... " "head (output)"
# diff -w -y <(./$EXECUTABLE norvig_count_1w.txt norvig_smaller.txt | head) <(output_head) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

# printf " %-40s ... " "head (output)"
# diff -w -y <(cat $WORKSPACE/uncommon | head) <(output_head) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

printf " %-40s ... " "head (output)"
diff -w -y <(cat $WORKSPACE/uncommon | head) <(output_tiny) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

# printf " %-40s ... " "tail (output)"
# diff -w -y <(./$EXECUTABLE norvig_count_1w.txt norvig_smaller.txt | tail) <(output_tail) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

# printf " %-40s ... " "tail (output)"
# diff -w -y <(cat $WORKSPACE/uncommon | tail) <(output_tail) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

# printf " %-40s ... " "wc   (output)"
# diff -w -y <(./$EXECUTABLE norvig_count_1w.txt norvig_smaller.txt | wc) <(output_wc) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

# printf " %-40s ... " "wc   (output)"
# diff -w -y <(cat $WORKSPACE/uncommon | wc) <(output_wc) &> $WORKSPACE/test
# if [ $? -ne 0 ]; then
#     error "Failure"
# else
#     echo "Success"
# fi

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
