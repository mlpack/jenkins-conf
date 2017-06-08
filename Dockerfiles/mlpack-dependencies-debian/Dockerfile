#Using ubuntu's latest image as base-image
FROM debian:latest

RUN apt-get update  && apt-get install -y aptitude && apt-get purge -y \
	$(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired! \
    ~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools' \
    | awk '{print $2}') && apt-get purge -y aptitude && apt-get autoremove -y && \
    apt-get clean && rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_*



#Installing dependencies required to run mlpack
RUN apt-get update  && apt-get install -y --no-install-recommends wget \
	libboost-math-dev libboost-program-options-dev libboost-test-dev \
	libboost-serialization-dev libarmadillo-dev cmake g++ binutils-dev make \
	g++ txt2man && apt-get clean && rm -rf /usr/share/man/?? && \
	rm -rf /usr/share/man/??_* && rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/locale/* && rm -rf /var/cache/debconf/*-old && \
    rm -rf /usr/share/doc/*


#creating a non-root user
RUN adduser --system --disabled-password --disabled-login --shell \
	/bin/sh mlpack

#Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done


#Setting up non-root user
USER mlpack

# #downloading the source files and extracting them
# RUN wget -c http://www.mlpack.org/files/mlpack-2.2.0.tar.gz
# RUN tar -xvzf mlpack-2.2.0.tar.gz

# #making build dir
# RUN cd mlpack-2.2.0 && mkdir build
# WORKDIR mlpack-2.2.0/build


# #making the project
# RUN cmake ../ls

# RUN make
# RUN bin/mlpack_test -t KNNTest




