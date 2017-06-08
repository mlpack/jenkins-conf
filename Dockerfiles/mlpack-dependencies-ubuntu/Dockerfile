#Using ubuntu's latest image as base-image
FROM ubuntu:latest

#Installing dependencies required to run mlpack
RUN apt-get update && apt-get install -y wget libboost-math-dev \
    libboost-program-options-dev libboost-test-dev libboost-serialization-dev \
    libarmadillo-dev binutils-dev cmake build-essential git \
    && rm -rf /var/lib/apt/lists/*

#creating a non-root user
RUN adduser --system --no-create-home --disabled-password --disabled-login \
    --shell /bin/sh mlpack

#Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

#Setting up non-root user
USER mlpack

# # The following commands can be run to build and test different versions of mlpack 
# #changing work dir to make the mlpack project in /opt directory
# WORKDIR /opt

# #downloading the source files and extracting them
# RUN wget -c http://www.mlpack.org/files/mlpack-2.2.0.tar.gz
# RUN tar -xvzf mlpack-2.2.0.tar.gz

# #making build dir
# RUN cd mlpack-2.2.0 && mkdir build
# WORKDIR mlpack-2.2.0/build


# #making the project
# RUN cmake ../
# RUN make
# RUN bin/mlpack_test



