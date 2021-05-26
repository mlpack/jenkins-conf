FROM ubuntu:20.04

LABEL maintainer="marcus.edel@fu-berlin.de"

## For apt to be noninteractive.
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime

# Update software repository, install dependencies.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bubblewrap \
    bzip2 \
    cmake \
    curl \
    clang \
    git \
    libc6-dev \
    libgmp-dev \
    libmpfr-dev \
    libsqlite3-dev \
    make \
    patch \
    patchelf \
    pkg-config \
    python3.7 \
    libensmallen-dev \
    libstb-dev \
    python3-distutils \
    unzip \
    xz-utils \
    zlib1g-dev \
    python3-pip \
    wget \
    libopenblas-dev \
    liblapack-dev \
    binutils-dev \
    libboost-all-dev \
    txt2man \
    doxygen \
    sudo \
    gnupg \
    libarmadillo-dev \
    libcereal-dev \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
    pandas setuptools

# Install PVS-Studio.
RUN wget -O - https://files.viva64.com/etc/pubkey.txt | sudo apt-key add - \
    && sudo wget -O /etc/apt/sources.list.d/viva64.list \
    https://files.viva64.com/etc/viva64.list && apt-get update && \
    apt-get install -y pvs-studio

# Install Deepcode.
RUN pip3 install deepcode

# Install Infer.
RUN VERSION=1.1.0; \
    curl -sSL "https://github.com/facebook/infer/releases/download/v$VERSION/infer-linux64-v$VERSION.tar.xz" \
    | tar -C /opt -xJ && \
    ln -s "/opt/infer-linux64-v$VERSION/bin/infer" /usr/local/bin/infer

RUN useradd -rm -d /home/mlpack -s /bin/bash -g root -G sudo -u 1001 mlpack

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
USER mlpack
WORKDIR /home/mlpack
CMD /bin/bash
