#!/bin/bash

# Options
WORKER=1
REPORT_DIR="reports/tests"
CMAKE_FILE="./src/ensmallen/tests/CMakeLists.txt"

echo "Wipe out old reports."
mkdir -p $REPORT_DIR
rm -rf $REPORT_DIR/*

echo "Finding test cases."
./parse-ensmallen-tests.py $CHANGED_FILES $CMAKE_FILE > testbins.txt

# Replace '/' with '_' from test bin to create logfile.
logfile=ensmallen.memcheck
xmllogfile=ensmallen.xml

# Copy data to the correct directory.
cp -vr build/data/ data/

echo "Running all tests."
cat testbins.txt | xargs -n 1 -P $WORKER -I % ./memory-check.sh %
