#!/bin/bash

# Options
TEST_DIR="build/bin"
TEST_OPTS="-r junit -o reports/tests/result.xml"

echo "Wipe out old reports"
mkdir -p reports/tests/
rm -rf reports/tests/*

echo "Copy CSV files for tests to current working directory"
cp ./*/src/mlpack/tests/data/* .

echo "Unpack compressed test data"
TEST_DATA_ARCHIVE=$(find . -maxdepth 1 -iname "*bz2")
for TEST_DATA in ${TEST_DATA_ARCHIVE}
do
    echo "Extract $TEST_DATA"
    tar -xvjpf $TEST_DATA
done

echo "Running All Tests:"
./$TEST_DIR/mlpack_test $TEST_OPTS

# Try to remove invalid tag that JUnit doesn't parse.
sed -i 's/status=".*"//' reports/tests/result.xml;

echo "Cleaning up working directory"
rm test_data*
