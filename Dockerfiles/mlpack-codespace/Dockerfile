FROM mcr.microsoft.com/devcontainers/universal:focal

LABEL maintainer="james.balamuta@gmail.com"

## For apt to be noninteractive.
ENV DEBCONF_NONINTERACTIVE_SEEN true

## Install baseline dependencies not found in the devcontainer
## For details on what's included, please see:
## https://github.com/devcontainers/images/tree/main/src/universal
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    binutils-dev \ 
    txt2man \
    doxygen \
    liblapack-dev \
    libblas-dev \
    libarpack2 \
    libsuperlu-dev \
    libstb-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
    pandas setuptools

## Install armadillo.
RUN curl -Lk https://files.mlpack.org/armadillo-11.4.1.tar.gz | tar -xvz && \
    cd armadillo* && \
    cmake . && \
    make && \
    sudo make install && \
    cd .. 

## Install ensmallen.
RUN wget http://ensmallen.org/files/ensmallen-2.19.0.tar.gz && \
    tar -xf ensmallen-2.19.0.tar.gz && \
    cd ensmallen-2.19.0 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install && \
    cd ..

## Remove scripts now that we're done with them
RUN apt-get clean -y && rm -rf \
    armadillo* \
    ensmallen*

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
CMD /bin/bash
