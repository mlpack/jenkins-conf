#!/bin/bash

TEST_DIR="build/bin"
REPORT_DIR="reports/tests"

# Replace '/' with '_' from test bin to create logfile.
logfile=$(sed 's#/#_#g' <<<  $1).memcheck
xmllogfile=$(sed 's#/#_#g' <<<  $1).valgrind.xml
testxmlfile=$(sed 's#/#_#g' <<<  $1).boost_test.xml

# Run valgrind.
cd build/
valgrind --tool=memcheck --leak-check=full --track-origins=yes \
         --num-callers=40 --error-exitcode=1 --xml=yes --xml-file=$REPORT_DIR/$xmllogfile --log-file=$REPORT_DIR/$logfile \
         --verbose -- bin/mlpack_test --report_level=detailed --log_level=test_suite --log_format=XML -t $1 \
        > $testxmlfile;
cd ../
