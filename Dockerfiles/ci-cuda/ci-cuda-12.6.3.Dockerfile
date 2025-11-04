FROM nvidia/cuda:12.6.3-devel-ubuntu22.04

LABEL maintainer="marcus@kurg.org"

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
    nvidia-opencl-dev \
    ocl-icd-libopencl1 \
    opencl-headers \
    clinfo \
    libclblas-dev \
    && ln -s /usr/local/cuda-12.6/targets/x86_64-linux/lib/libcudart.so /usr/lib/libcudart.so

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN useradd -ms /bin/bash jenkins

# Setup environment.
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.6/targets/x86_64-linux/lib/:$LD_LIBRARY_PATH"
ENV CPLUS_INCLUDE_PATH="/usr/local/cuda-12.6/targets/x86_64-linux/include/:$CPLUS_INCLUDE_PATH"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

USER jenkins
WORKDIR /home/jenkins
CMD /bin/bash

