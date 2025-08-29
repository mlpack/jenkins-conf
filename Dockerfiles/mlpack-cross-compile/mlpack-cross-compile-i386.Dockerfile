FROM ubuntu:16.04

RUN apt-get -yy update
RUN apt-get install -yy vim git make cmake bzip2 wget curl bison g++ libncurses-dev python cpio unzip bc

RUN git clone https://github.com/rcurtin/buildroot
RUN cd buildroot/ && git checkout 386-hacks && make && cd /

# Move the result to the right place.
RUN mkdir -p /opt/i386-buildroot-linux-uclibc/
RUN cp -r /buildroot/output/host/usr/* /opt/i386-buildroot-linux-uclibc/
RUN rm -rf /buildroot

RUN sed -i 's/xenial/focal/g' /etc/apt/sources.list
RUN apt-get -yy update && apt-get -yy upgrade && apt-get -yy dist-upgrade

RUN git clone https://github.com/mlpack/mlpack
RUN cd mlpack/
RUN mkdir build/
RUN cd build/
