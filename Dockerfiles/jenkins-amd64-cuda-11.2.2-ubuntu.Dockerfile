FROM nvidia/cuda:11.2.2-devel-ubuntu20.04

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
    cmake \
    gcc \
    g++ \
    git \
    make \
    libarmadillo-dev \
    build-essential \
    libclblas-dev \
    nsight-compute \
    && ln -s /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudart.so /usr/lib/libcudart.so

RUN useradd -ms /bin/bash jenkins

# Setup environment.
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.2/targets/x86_64-linux/lib/:$LD_LIBRARY_PATH"
ENV CPLUS_INCLUDE_PATH="/usr/local/cuda-11.2/targets/x86_64-linux/include/:$CPLUS_INCLUDE_PATH"
USER jenkins
WORKDIR /home/jenkins
CMD /bin/bash
