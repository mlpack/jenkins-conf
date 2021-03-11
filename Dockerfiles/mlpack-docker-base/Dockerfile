# Using debian's latest image as base-image.
FROM debian:bullseye

# Steps to reduce image size.
RUN apt-get update  && apt-get install -y aptitude && apt-get purge -y \
    $(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired! \
    ~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools' \
    | awk '{print $2}' ) && apt-get purge -y aptitude && \
    apt-get autoremove -y && apt-get clean && rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Installing dependencies required to run mlpack.
RUN apt-get update  && apt-get install -y --no-install-recommends wget \
    cmake binutils-dev make txt2man git build-essential \
    doxygen unzip liblapack-dev libblas-dev libarpack2 libsuperlu-dev && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_* && \
    rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && rm -rf /usr/share/doc/*
