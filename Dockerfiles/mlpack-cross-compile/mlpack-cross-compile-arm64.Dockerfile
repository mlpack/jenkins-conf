FROM debian:stable

LABEL maintainer="ryan@ratml.org"

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
    unzip \
    xz-utils \
    libopenblas-dev \
    binutils-dev \
    libcereal-dev \
    txt2man \
    wget \
    ca-certificates \
    openssh-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the cortexa76 cross-compilation environment.
RUN curl -Lk https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2024.02-1.tar.bz2 |\
    tar -xvjC /opt/;

ENV TOOLCHAIN_PREFIX=/opt/aarch64--glibc--stable-2024.02-1/bin/aarch64-buildroot-linux-gnu-
ENV CMAKE_SYSROOT=/opt/aarch64--glibc--stable-2024.02-1/aarch64-buildroot-linux-gnu/sysroot

# On the cross-compile hosts used for this job, the uid will be 1001, but it's
# possible someone might want to run this container with a different uid, so
# just set the workspace to a directory where anyone can write.
RUN mkdir /workspace
RUN chmod -R 777 /workspace

RUN groupadd -g 1001 jenkins
RUN useradd -rm -d /home/jenkins -s /bin/bash -g jenkins -u 1001 jenkins
USER jenkins

# Paranoia: make sure another user can write to the home directory too.
RUN chmod -R 777 /home/jenkins
WORKDIR /workspace

CMD /bin/bash
