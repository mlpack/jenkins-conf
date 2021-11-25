# Dockerfile to build docs for mlpack.
FROM ubuntu:21.04

LABEL maintainer="kaushikaakash7539@gmail.com"

## For apt to be noninteractive.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -y \
    python3 \
    python3-pip \
    doxygen \
    git \
    python3-sphinx \
    make && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install --upgrade --ignore-installed \
    breathe \
    exhale \
    karma-sphinx-theme

RUN useradd -ms /bin/bash jenkins

# Setup environment.
ENV LD_LIBRARY_PATH /usr/local/lib
USER jenkins
WORKDIR /home/jenkins
CMD /bin/bash
