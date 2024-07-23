FROM mcr.microsoft.com/devcontainers/universal:focal

LABEL maintainer="james.balamuta@gmail.com"

## For apt to be noninteractive.
ENV DEBCONF_NONINTERACTIVE_SEEN true

## Install baseline dependencies not found in the devcontainer
## For details on what's included, please see:
## https://github.com/devcontainers/images/tree/main/src/universal
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    binutils-dev \ 
    txt2man \
    doxygen \
    liblapack-dev \
    libblas-dev \
    libarpack2 \
    libsuperlu-dev \
    libcereal-dev \
    libstb-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed cython numpy \
    pandas setuptools

# Add a run step for R and R packages.
# Attempt tog et R packages from the cran40 repository.
# Note, this is tagged to the focal release! Change me.
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc \
    && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/"\
    && add-apt-repository "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu focal main" \
    && echo "Package: *" > /etc/apt/preferences.d/99cranapt \
    && echo "Pin: release o=CRAN-Apt Project" >> /etc/apt/preferences.d/99cranapt \
    && echo "Pin: release l=CRAN-Apt Packages" >> /etc/apt/preferences.d/99cranapt \
    && echo "Pin-Priority: 700"  >> /etc/apt/preferences.d/99cranapt \
    && apt update -qq \
    && apt -y install r-base r-base-dev \
    && apt -y install r-cran-rcpp r-cran-rcpparmadillo r-cran-devtools r-cran-testthat \
    && apt -y install r-cran-languageserver r-cran-httpgd r-cran-rcppensmallen 

## Install armadillo.
RUN curl -Lk https://files.mlpack.org/armadillo-11.4.1.tar.gz | tar -xvz && \
    cd armadillo* && \
    cmake . && \
    make && \
    sudo make install && \
    cd .. 

## Install ensmallen.
RUN wget http://ensmallen.org/files/ensmallen-2.19.0.tar.gz && \
    tar -xf ensmallen-2.19.0.tar.gz && \
    cd ensmallen-2.19.0 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install && \
    cd ..

## Remove scripts now that we're done with them
RUN apt-get clean -y && rm -rf \
    armadillo* \
    ensmallen*

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
CMD /bin/bash
