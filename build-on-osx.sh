#!/bin/bash
# Install mlpack on OSX 10.11 (EI Capitan) 

# assume we are in the root of mlpack project
# CMake and Xcode Command Line Tools are required

# git clone https://github.com/mlpack/mlpack
# cd mlpack

mkdir build
cd build

# compile armadillo and install for all user
curl -O http://tenet.dl.sourceforge.net/project/arma/armadillo-6.500.5.tar.gz
tar zxvf armadillo-6.500.5.tar.gz
cd armadillo-6.500.5
./configure
make -j4
make install
cd ..

# compile boost and and install for all user
curl -O http://netcologne.dl.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz
tar zxvf boost_1_60_0.tar.gz
cd boost_1_60_0
sh bootstrap.sh
./b2 install
cd ..

# compile mlpack
cmake -DDEBUG=OFF -DPROFILE=OFF ..
make -j4

# we do not need performance install on a build server
# make install