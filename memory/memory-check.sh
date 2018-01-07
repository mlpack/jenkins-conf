#!/bin/bash

TEST_DIR="build/bin"
REPORT_DIR="reports/tests"

# Replace '/' with '_' from test bin to create logfile.
logfile=$(sed 's#/#_#g' <<<  $1).memcheck
xmllogfile=$(sed 's#/#_#g' <<<  $1).xml

# Run valgrind.
valgrind --tool=memcheck --leak-check=full --track-origins=yes \
         --num-callers=40 --error-exitcode=1 --xml=yes --xml-file=$REPORT_DIR/$xmllogfile --log-file=$REPORT_DIR/$logfile \
         --verbose build/bin/mlpack_test -t $1
