# Download base image ubuntu 16.04.
FROM ubuntu:16.04

# Meta information.
LABEL maintainer="marcus.edel@fu-berlin.de"

# Get mlpack version.
ARG mlpack_archive

# Update software repository, install dependencies and build mlpack.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends python3-pip cmake wget sudo \
    libopenblas-dev liblapack-dev binutils-dev libboost-all-dev pkg-config \
    make txt2man git doxygen libarmadillo-dev build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
    pandas setuptools && \
    adduser mlpack sudo && su mlpack && cd /home/mlpack/ && \
    wget -O mlpack.tar.gz ${mlpack_archive} && \
    tar -xvzpf mlpack.tar.gz && cd * && mkdir build && \
    cd build && cmake -DPYTHON=/usr/bin/python3 .. && make && make install && \
    cd .. && rm -rf build

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
USER mlpack
WORKDIR /home/mlpack
CMD /bin/bash
