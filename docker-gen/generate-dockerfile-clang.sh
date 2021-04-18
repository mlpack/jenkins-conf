#!/bin/bash

arma_version=$1
boost_version=$2
cereal_version=$3
llvm_version=$4

llvm_version_major=`echo ${llvm_version/llvm-} | sed 's/^\([0-9]\).*/\1/'`;

cat > Dockerfile <<EOF
# Using debian:stretch image as base-image plus mlpack prereqs.
FROM mlpack-docker-base:latest

# Installing clang from source.
WORKDIR /
RUN apt-get update -qq && apt-get install -y python && \
    wget http://files.mlpack.org/$llvm_version.tar.xz && \
    tar xvf $llvm_version.tar.xz && \
    rm -f $llvm_version.tar.xz && \
    cd $llvm_version && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_BUILD_TYPE=Release -DLLVM_OPTIMIZED_TABLEGEN=ON ../ && \
    make -j32 && \
    make install && \
    cd ../../ && \
    rm -rf $llvm_version && \
    apt-get purge -y python && apt-get remove -y gfortran gcc && \
    apt-get autoremove -y && apt-get install -y libstdc++-6-dev bzip2 && \
    apt-get clean && rm -rf /usr/share/man/?? && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/man/??_*

# Installing boost from source.  On newer LLVM versions, we have to change
# -emit-pth in the Boost sources to -emit-pch.
WORKDIR /
RUN wget \
      http://files.mlpack.org/$boost_version.tar.gz && \
    tar xvzf $boost_version.tar.gz && \
    rm -f $boost_version.tar.gz && \
    cd $boost_version && \
    if [ $llvm_version_major -ge 9 ]; then \
      echo "modifying file!" && \
      cat tools/build/v2/tools/clang-linux.jam && \
      sed -i 's/-emit-pth/-emit-pch/' tools/build/v2/tools/clang-linux.jam && \
      cat tools/build/v2/tools/clang-linux.jam; \
    fi && \
    ./bootstrap.sh --with-toolset=clang --prefix=/usr/ \
        --with-libraries=math,program_options,serialization,test && \
    if [ ! -f "bjam" ]; then \
      ./b2 install; \
    else \
      ./bjam install; \
    fi && \
    cd .. && \
    rm -rf $boost_version/

# Installing armadillo via source-code.  We have to manually reinstall BLAS and
# LAPACK since they were purged with gcc.
WORKDIR /
RUN apt-get update -qq && apt-get install -y liblapack-dev libblas-dev libsuperlu-dev && \
    apt-get autoremove -y && apt-get clean && rm -rf /usr/share/man/?? && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/man/??_* && \
    wget --no-check-certificate \
        "http://files.mlpack.org/$arma_version.tar.gz" && \
    tar xvzf $arma_version.tar.gz && \
    rm -f $arma_version.tar.gz && \
    cd $arma_version && \
    cmake -DINSTALL_LIB_DIR=/usr/lib/ . && \
    make -j32 && \
    make install && \
    cd .. && \
    rm -rf $arma_version

# Install cereal headers.
# We install directly to /usr/include/ which is a little ugly but hey we aren't
# ever going to use these Docker containers as a real system so we can get away
# with it...
RUN wget --no-check-certificate \
    http://files.mlpack.org/$cereal_version.tar.gz && \
    tar xvzf $cereal_version.tar.gz && \
    rm -f $cereal_version.tar.gz && \
    cd $cereal_version && \
    cp -vr include/ /usr/include/ && \
    cd .. && \
    rm -rf $cereal_version
EOF

cat >> Dockerfile << 'EOF'
# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Hardening the containers by unsetting all SUID tags.
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

# Changing work directory and user to mlpack.
WORKDIR /home/mlpack
USER mlpack
EOF
