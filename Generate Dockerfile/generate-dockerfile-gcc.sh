#!/bin/bash

arma_version=$1
boost_version=$2
gcc_version=$3

cat > Dockerfile <<EOF

# Using debian's latest image as base-image.
FROM debian:stretch

# Steps to reduce image size.
RUN apt-get update  && apt-get install -y aptitude && apt-get purge -y \
    \$(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired! \
    ~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools' \
    | awk '{print $2}' ) && apt-get purge -y aptitude && \
    apt-get autoremove -y && apt-get clean && rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Installing dependencies required to run mlpack.
RUN apt-get update  && apt-get install -y --no-install-recommends wget \
    cmake binutils-dev make txt2man git build-essential  \
    doxygen  unzip liblapack-dev libblas-dev libarpack2 libsuperlu-dev && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/*


#Installing gcc from source
RUN wget --no-check-certificate\
   https://ftp.gnu.org/gnu/gcc/$gcc_version/$gcc_version.tar.gz \
    && tar xvzf $gcc_version.tar.gz && rm -r $gcc_version.tar.gz
WORKDIR $gcc_version
RUN ./contrib/download_prerequisites && cd .. && mkdir objdir && cd objdir && \
   \$PWD/../$gcc_version/configure --prefix=/usr --enable-languages=c,c++,fortran \
    --disable-multilib --disable-bootstrap && make -j8 && make install

# Installing armadillo via source-code.
WORKDIR /
RUN wget --no-check-certificate \
    http://masterblaster.mlpack.org:5005/$arma_version.tar.gz \
    && tar xvzf $arma_version.tar.gz && rm -r $arma_version.tar.gz
WORKDIR $arma_version
RUN cmake -DINSTALL_LIB_DIR=/usr/lib . && make -j8  && make install

# Installing boost from source
WORKDIR /
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/$boost_version.tar.gz" \
    && tar xvzf $boost_version.tar.gz && rm -r $boost_version.tar.gz
WORKDIR $boost_version
RUN ./bootstrap.sh  --prefix=/usr/  \
    --with-libraries=math,program_options,serialization,test
RUN ./bjam install -j8

# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Hardening the containers by unsetting all SUID tags
RUN for i in "find / -perm 6000 -type f"; do chmod a-s $i; done


# Changing work directory again.
WORKDIR /home/mlpack

USER mlpack

# The following commands can be run to build and test different versions of
# The following commands can be run to build and test different versions of
# mlpack.

# Downloading the source files and extracting them.
#RUN wget -c http://www.mlpack.org/files/mlpack-2.2.0.tar.gz
#RUN tar -xvzf mlpack-2.2.0.tar.gz


# Making build directory.
#RUN cd mlpack-2.2.0 && mkdir build
#WORKDIR mlpack-2.2.0/build

# Making the project.
#RUN cmake  ../
#RUN make
#RUN bin/mlpack_test

EOF
