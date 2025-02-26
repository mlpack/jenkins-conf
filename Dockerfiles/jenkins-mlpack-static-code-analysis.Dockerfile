# Dockerfile to perform static code analysis for mlpack.
FROM debian:unstable

LABEL maintainer="ryan@ratml.org"

## For apt to be noninteractive.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -yy g++ libopenblas-dev libarmadillo-dev libstb-dev libcereal-dev cmake git curl xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install infer.
RUN curl -sSL "https://github.com/facebook/infer/releases/download/v1.2.0/infer-linux-x86_64-v1.2.0.tar.xz" | tar -C /opt -xJ && \
    ln -s "/opt/infer-linux-x86_64-v1.2.0/bin/infer" /usr/local/bin/infer

# All Jenkins builds in Docker containers run as uid 1000.
RUN groupadd jenkins
RUN useradd -rm -d /home/jenkins -s /bin/bash -g jenkins -u 1000 jenkins
USER jenkins
WORKDIR /home/jenkins

CMD /bin/bash
