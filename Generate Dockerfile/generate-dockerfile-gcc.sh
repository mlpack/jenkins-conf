#!/bin/bash

arma_version=$1
boost_version=$2
gcc_version=$3

cat > Dockerfile << EOF

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
    doxygen unzip liblapack-dev libblas-dev libarpack2 libsuperlu-dev && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/*


#Installing gcc from source
RUN wget --no-check-certificate \
   https://ftp.gnu.org/gnu/gcc/$gcc_version/$gcc_version.tar.gz && \
   tar xvzf $gcc_version.tar.gz && \
   rm -f $gcc_version.tar.gz && \
   cd $gcc_version && \
   ./contrib/download_prerequisites && \
   mkdir objdir && \
   cd objdir && \
   ../configure --prefix=/usr --enable-languages=c,c++,fortran \
     --disable-multilib --disable-bootstrap && \
   make && \
   make install && \
   cd ../ && \
   rm -rf $gcc_version

# Installing armadillo via source-code.
RUN wget --no-check-certificate \
    http://masterblaster.mlpack.org:5005/$arma_version.tar.gz && \
    tar xvzf $arma_version.tar.gz && \
    rm -f $arma_version.tar.gz && \
    cd $arma_version && \
    cmake -DINSTALL_LIB_DIR=/usr/lib . && \
    make && \
    make install && \
    cd .. && \
    rm -rf $arma_version

# Installing boost from source
RUN wget --no-check-certificate \
      "http://masterblaster.mlpack.org:5005/$boost_version.tar.gz" && \
    tar xvzf $boost_version.tar.gz && \
    rm -f $boost_version.tar.gz && \
    cd $boost_version && \
    ./bootstrap.sh --prefix=/usr/ \
        -with-libraries=math,program_options,serialization,test && \
    ./bjam install && \
    cd ../ && \
    rm -rf $boost_version
WORKDIR $boost_version

EOF

cat >> Dockerfile << 'EOF'
# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

# Changing work directory again.
WORKDIR /home/mlpack
USER mlpack
EOF
