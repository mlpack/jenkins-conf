#!/bin/bash

arma_version=$1
boost_version=$2
cereal_version=$3
gcc_version=$4

gcc_version_major=`echo ${gcc_version/gcc-} | sed 's/^\([0-9]\).*/\1/'`;

cat > Dockerfile << EOF
# Using debian's latest image as base-image plus mlpack prereqs.
FROM mlpack.org:5000/mlpack-docker-base:latest

# Installing gcc from source.  On newer gcc versions than the system gcc, we
# have to move all the libraries and bootstrap.
RUN wget --no-check-certificate \
   https://files.mlpack.org/$gcc_version.tar.gz && \
   tar xvzf $gcc_version.tar.gz && \
   rm -f $gcc_version.tar.gz && \
   cd $gcc_version && \
   ./contrib/download_prerequisites && \
   mkdir objdir && \
   cd objdir && \
   if [ $gcc_version_major -gt 8 ]; then \
     ../configure --prefix=/usr --enable-languages=c,c++,fortran \
        --disable-multilib --enable-bootstrap; \
   elif [ $gcc_version_major -gt 6 ]; then \
     ../configure --prefix=/usr --enable-languages=c,c++,fortran \
        --disable-multilib --enable-bootstrap --disable-libsanitizer; \
   else \
     ../configure --prefix=/usr --enable-languages=c,c++,fortran \
       --disable-multilib --disable-bootstrap --disable-libsanitizer; \
   fi && \
   make && \
   make install && \
   mv /usr/lib64/* /usr/lib/x86_64-linux-gnu/ && \
   cd ../../ && \
   rm -rf $gcc_version

# Installing boost from source
RUN wget --no-check-certificate \
      "http://files.mlpack.org/$boost_version.tar.gz" && \
    tar xvzf $boost_version.tar.gz && \
    rm -f $boost_version.tar.gz && \
    cd $boost_version && \
    cp -r boost/ /usr/include/ && \
    cd ../ && \
    rm -rf $boost_version

# Installing armadillo via source-code.
RUN wget --no-check-certificate \
    http://files.mlpack.org/$arma_version.tar.gz && \
    tar xvzf $arma_version.tar.gz && \
    rm -f $arma_version.tar.gz && \
    cd $arma_version && \
    cmake -DINSTALL_LIB_DIR=/usr/lib . && \
    make && \
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

# Hardening the containers by unsetting all SUID tags
RUN for i in `find / -perm 6000 -type f`; do chmod a-s $i; done

# Changing work directory again.
WORKDIR /home/mlpack
USER mlpack
EOF
