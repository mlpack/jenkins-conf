# Using debian's latest image as base-image.
FROM debian:stretch

# Steps to reduce image size.
RUN apt-get update  && apt-get install -y aptitude && apt-get purge -y \
    $(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired! \
    ~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools' \
    | awk '{print $2}') && apt-get purge -y aptitude && \
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
RUN wget --no-check-certificate \
    "https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.gz" && \
    tar xvzf gcc-6.2.0.tar.gz && \
    rm -r gcc-6.2.0.tar.gz && \
    cd gcc-6.2.0 && \
    ./contrib/download_prerequisites && \
    mkdir objdir && \
    cd objdir && \
    $PWD/../configure --prefix=/usr --enable-languages=c,c++,fortran \
      --disable-multilib --disable-bootstrap && \
    make -j8 && \
    make install && \
    cd ../../ && \
    rm -rf gcc-6.2.0/

# Installing armadillo via source-code.
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/armadillo-6.500.5.tar.gz" && \
    tar xvzf armadillo-6.500.5.tar.gz && \
    rm -r armadillo-6.500.5.tar.gz && \
    cd armadillo-6.500.5 && \
    cmake -DINSTALL_LIB_DIR=/usr/lib . && \
    make -j8 && \
    make install && \
    cd .. && \
    rm -rf armadillo-6.500.5/

# Installing boost from source
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/boost_1_49_0.tar.gz" && \
    tar xvzf boost_1_49_0.tar.gz && \
    rm -r boost_1_49_0.tar.gz && \
    cd boost_1_49_0 && \
    ./bootstrap.sh  --prefix=/usr/  \
    --with-libraries=math,program_options,serialization,test && \
    ./bjam install -j8 && \
    cd / && \
    rm -rf boost_1_49_0/

# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

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
