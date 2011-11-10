#!/bin/bash

DATA_FILE="reports/sloccount.sc"
DATA_DIR="reports/slocdata"
SRC_DIR="repo"

if [ ! -d $DATA_DIR ]
then
  mkdir -p $DATA_DIR
fi

sloccount --wide --details --datadir $DATA_DIR ${SRC_DIR}/CMake $SRC_DIR/CMakeLists.txt ${SRC_DIR}/src > $DATA_FILE

#mv $DATA_FILE $DATA_DIR
