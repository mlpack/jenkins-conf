#!/bin/bash

# Options
WORKER=6
REPORT_DIR="reports/tests"
CMAKE_FILE="./src/ensmallen/tests/CMakeLists.txt"
TEST_PATH="./src/ensmallen/tests/"

echo "Wipe out old reports."
mkdir -p $REPORT_DIR
rm -rf $REPORT_DIR/*

echo "Running all tests."

# Replace '/' with '_' from test bin to create logfile.
logfile=ensmallen.memcheck
xmllogfile=ensmallen.xml

# Run valgrind.
valgrind --tool=memcheck --leak-check=full --track-origins=yes \
         --num-callers=40 --error-exitcode=1 --xml=yes --xml-file=$REPORT_DIR/$xmllogfile --log-file=$REPORT_DIR/$logfile \
         --verbose build/ensmallen_tests
