#!/bin/bash

# Options
TEST_DIR="build/bin"
REPORT_DIR="reports/tests"
TEST_OPTS="--report_level=detailed --log_level=test_suite --log_format=XML"
XML_REGEX="[:print:]"

echo "Wipe out old reports"
mkdir -p $REPORT_DIR
rm -rf $REPORT_DIR/*

echo "Finding test Binaries"
TEST_BINS=$(find $TEST_DIR -iname "*_test")

echo "Copy CSV files for tests to current working directory"
cp ./*/src/mlpack/tests/data/* .

echo "Unpack mnist_first250_training_4s_and_9s.arm for sparse coding tests"
tar -xvjpf mnist_first250_training_4s_and_9s.tar.bz2

echo "Running All Tests:"
for ML_TEST in ${TEST_BINS}
do
   echo "[$(basename $(pwd))] $ML_TEST"
   ./$ML_TEST $TEST_OPTS > $REPORT_DIR/$(basename $ML_TEST).xml
done

echo "Finding Boost.Test Results:"
BOOST_RESULTS=$(grep -l "<TestLog>" $REPORT_DIR/*)
for BOOST_TEST in ${BOOST_RESULTS}
do
   BOOST_BASENAME=$(basename $BOOST_TEST)
   echo "Found boost_$BOOST_BASENAME"
   # Split tags into lines.
   cat $BOOST_TEST | sed 's/>/>\n/g' | tr -cd  $XML_REGEX > $REPORT_DIR/boost_$BOOST_BASENAME

   echo "Remove unsupported xml tags:"
   ./test-support/xml_boost_test.py $REPORT_DIR/boost_$BOOST_BASENAME > $REPORT_DIR/tmp_boost_$BOOST_BASENAME
   mv $REPORT_DIR/tmp_boost_$BOOST_BASENAME $REPORT_DIR/boost_$BOOST_BASENAME
done

echo "Cleaning up working directory"
rm test_data*
