#!/bin/bash

# Options
WORKER=1
REPORT_DIR="reports/tests"
CHANGED_FILES="filenames.txt"
CMAKE_FILE="./src/mlpack/tests/CMakeLists.txt"
TEST_PATH="./src/mlpack/tests/"

echo "Wipe out old reports."
mkdir -p $REPORT_DIR
rm -rf $REPORT_DIR/*

echo "Finding test cases."
./parse-tests.py $CHANGED_FILES $CMAKE_FILE $TEST_PATH > testbins.txt

echo "Copy CSV files for tests to current working directory"
cp ./src/mlpack/tests/data/* build/

echo "Running all tests."
cat testbins.txt | xargs -n 1 -P $WORKER -I % ./memory-check.sh %
