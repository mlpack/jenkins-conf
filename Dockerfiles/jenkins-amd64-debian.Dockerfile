FROM debian:bookworm

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
        ccache \
        pkg-config \
        python3.11 \
        python3-distutils \
        unzip \
        valgrind \
        xz-utils \
        python3-pip \
        python3-setuptools \
        cython3 \
        python3-pandas \
        python3-wheel \
        python3-numpy \
        wget \
        libopenblas-dev \
        liblapack-dev \
        binutils-dev \
        libcereal-dev \
        txt2man \
        sloccount \
        sudo \
        gnupg \
        build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install armadillo.
RUN curl -Lk https://files.mlpack.org/armadillo-14.4.0.tar.xz | tar -xvJ && \
    cd armadillo* && \
    cmake . && \
    make && \
    sudo make install && \
    cd ..

# Install ensmallen.
RUN wget http://ensmallen.org/files/ensmallen-2.22.1.tar.gz && \
    tar -xf ensmallen-2.22.1.tar.gz && \
    cd ensmallen-2.22.1 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install

RUN useradd -ms /bin/bash jenkins
RUN chmod -R 777 /home/jenkins/

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
USER jenkins
WORKDIR /home/jenkins
CMD /bin/bash
