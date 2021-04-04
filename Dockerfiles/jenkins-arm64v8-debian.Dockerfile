FROM arm64v8/debian:buster

LABEL maintainer="marcus.edel@fu-berlin.de"

## For apt to be noninteractive.
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    cmake \
    curl \
    gcc \
    g++ \
    git \
    make \
    pkg-config \
    python3.7 \
    python3-distutils \
    unzip \
    xz-utils \
    python3-pip \
    python3-setuptools \
    wget \
    libopenblas-dev \
    liblapack-dev \
    binutils-dev \
    libboost-all-dev \
    libcereal-dev \
    txt2man \
    doxygen \
    sudo \
    gnupg \
    libarmadillo-dev \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
    pandas setuptools

RUN useradd -ms /bin/bash jenkins

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
USER jenkins
WORKDIR /home/jenkins
CMD /bin/bash
