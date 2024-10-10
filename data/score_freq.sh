#!/bin/bash

# Configuration

PROGRAM=freq
EXECUTABLE=./$PROGRAM
WORKSPACE=/tmp/$PROGRAM.$(id -u)
POINTS=25
FAILURES=0

export LC_ALL=C

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

output_animals() {
    cat <<EOF
4       dog
3       bear
2       cat
1       armadillo
EOF
}

output_quotes() {
    cat <<EOF
9       the
6       of
6       and
4       to
4       our
3       we
3       that
3       for
3       are
2       with
EOF
}

output_ulysses() {
    cat <<EOF
the
of
and
a
to
in
he
his
i
that
EOF
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $PROGRAM ..."

printf " %-40s ... " "animals.txt (output)"
diff -wy <(./$EXECUTABLE < animals.txt | LC_ALL=C sort -rn) <(output_animals) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "animals.txt (valgrind)"
valgrind --leak-check=full ./$EXECUTABLE < animals.txt &> $WORKSPACE/test
if [ $? -ne 0 ] || [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "quotes.txt  (output)"
diff -wy <(./$EXECUTABLE < quotes.txt | LC_ALL=C sort -rn | head) <(output_quotes) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "ulysses.txt (output)"
diff -wy <(./$EXECUTABLE < ulysses.txt | LC_ALL=C sort -rn | head | awk '{print $2}') <(output_ulysses) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

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
