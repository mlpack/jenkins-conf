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
    cmake binutils-dev make txt2man git build-essential \
    doxygen liblapack-dev libblas-dev libarpack2 libsuperlu-dev unzip  && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/*

#Installing gcc from source
RUN wget --no-check-certificate\
    "https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.gz" \
    && tar xvzf gcc-6.2.0.tar.gz && rm -r gcc-6.2.0.tar.gz
WORKDIR gcc-6.2.0
RUN ./contrib/download_prerequisites && cd .. && mkdir objdir && cd objdir && \
    $PWD/../gcc-6.2.0/configure --prefix=/usr --enable-languages=c,c++,fortran \
    --disable-multilib --disable-bootstrap && make -j8 && apt-get purge -y gcc-4.9 && \
    make install



# Installing armadillo via source-code.
WORKDIR /
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/armadillo-4.600.5.tar.gz" \
    && tar xvzf armadillo-4.600.5.tar.gz && rm -r armadillo-4.600.5.tar.gz
WORKDIR armadillo-4.600.5
RUN cmake -DINSTALL_LIB_DIR=/usr/lib . && make -j8  && make install



# Installing armadillo via source-code.
WORKDIR /
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/armadillo-4.600.5.tar.gz" \
    && tar xvzf armadillo-4.600.5.tar.gz && rm -r armadillo-4.600.5.tar.gz
WORKDIR armadillo-4.600.5
RUN cmake . && make && make install && rm -rf /armadillo-4.600.5

# Creating a non-root user.
RUN adduser --system --disabled-password --disabled-login \
   --shell /bin/sh mlpack

# Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

# Installing boost from source
WORKDIR /
RUN wget --no-check-certificate \
    "http://masterblaster.mlpack.org:5005/boost_1_49_0.tar.gz" \
    && tar xvzf boost_1_49_0.tar.gz && rm -r boost_1_49_0.tar.gz
WORKDIR boost_1_49_0
RUN ./bootstrap.sh  --prefix=/usr/  \
    --with-libraries=math,program_options,serialization,test
RUN ./bjam install -j8


# Changing work directory again.
WORKDIR /home/mlpack


# The following commands can be run to build and test different versions of
# The following commands can be run to build and test different versions of
# mlpack.

# Downloading the source files and extracting them.
#RUN wget -c http://www.mlpack.org/files/mlpack-2.2.2.tar.gz
#RUN tar -xvzf mlpack-2.2.0.tar.gz

# Making build directory.
#RUN cd mlpack-2.2.0 && mkdir build
#WORKDIR mlpack-2.2.0/build

# Making the project.
#RUN cmake  ../
#RUN make
#RUN bin/mlpack_test    