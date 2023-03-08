# This is the mlpack/mlpack image on Dockerhub.

# Download base image ubuntu 22.04.
FROM ubuntu:22.04

# Meta information.
LABEL maintainer="marcus.edel@fu-berlin.de"

# Get mlpack version.
ARG mlpack_archive

# Update software repository and install dependencies.
RUN apt-get update -qq && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install -y --no-install-recommends python3-pip cmake wget sudo \
      libopenblas-dev liblapack-dev binutils-dev libboost-all-dev pkg-config \
      make txt2man git doxygen libarmadillo-dev build-essential golang \
      r-base golang-gonum-v1-gonum-dev libcereal-dev libstb-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
        pandas setuptools && \
    useradd -m mlpack -G sudo

# Download and install ensmallen.
RUN wget https://www.ensmallen.org/files/ensmallen-latest.tar.gz && \
    tar -xvzpf ensmallen-latest.tar.gz && \
    cd ensmallen-* && \
    mkdir build/ && \
    cd build/ && \
    cmake ../ && \
    make install && \
    cd ../../ && \
    rm -rf ensmallen-latest.tar.gz ensmallen-*/

# Note: it is assumed that the versions of these packages in the
# language-specific package managers are the same version used to build this
# package.

# Install Julia and mlpack.jl package.
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.3-linux-x86_64.tar.gz && \
    mkdir -p /opt/ && \
    tar -xvzpf julia-1.8.3-linux-x86_64.tar.gz -C /opt/ && \
    ln -s /opt/julia-1.8.3/bin/julia /usr/local/bin/julia && \
    /usr/local/bin/julia -e 'using Pkg; Pkg.add("mlpack")'

# Install and build Go bindings.
RUN GO111MODULE=off go get -d -u mlpack.org/v1/mlpack && \
    cd ~/go/src/mlpack.org/v1/mlpack/ && \
    make install

# Install mlpack R bindings.
RUN Rscript -e "install.packages('mlpack')"

USER mlpack
RUN cd /home/mlpack && \
    wget -O mlpack.tar.gz ${mlpack_archive} && \
    tar -xvzpf mlpack.tar.gz && \
    cd mlpack-*/ && \
    mkdir build && \
    cd build && \
    cmake \
        -DPYTHON_EXECUTABLE=`which python3` \
        -DBUILD_PYTHON_BINDINGS=ON \
        -DBUILD_CLI_EXECUTABLES=ON \
        -DDOWNLOAD_DEPENDENCIES=OFF \
        -DJULIA_EXECUTABLE=/usr/local/bin/julia \
        .. && \
    make -j4

USER root
RUN cd /home/mlpack/mlpack-*/build/ && \
    make install && \
    cd .. && \
    rm -rf build

# Setup environment.
USER mlpack
WORKDIR /home/mlpack
CMD /bin/bash
