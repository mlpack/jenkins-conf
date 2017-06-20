# Using debian's latest image as base-image.
FROM debian:latest

# Steps to reduce image size.
RUN apt-get update  && apt-get install -y aptitude && apt-get purge -y \
    $(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired! \
    ~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools' \
    | awk '{print $2}') && apt-get purge -y aptitude && \
    apt-get autoremove -y && apt-get clean && rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Installing dependencies required to run mlpack.
RUN apt-get update  && apt-get install -y --no-install-recommends wget \
    cmake binutils-dev make g++ txt2man git \
    doxygen liblapack-dev libblas-dev libarpack2 libsuperlu-dev unzip  && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/*

# Installing armadillo via source-code.
ADD armadillo-code /armadillo-code
WORKDIR armadillo-code
RUN cmake . && make && make install && rm -rf /armadillo-code

# Installing Boost from source
ADD boost_1_49_0 /boost_1_49_0
WORKDIR /boost_1_49_0
RUN ./bootstrap.sh --prefix=/usr \
    --with-libraries=math,program_options,serialization,test && ./b2 install

# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Giving permissions to user mlpack.
RUN chmod -R ugo+rw /usr && chown -R mlpack /usr

# Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

# Changing work directory.
WORKDIR /home/mlpack/

# Setting up non-root user.
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