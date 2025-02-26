# Dockerfile to build docs for mlpack.
FROM debian:unstable

LABEL maintainer="ryan@ratml.org"

## For apt to be noninteractive.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -yy python3 python3-venv git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# We don't know what uid the container will be running as, so just set the
# workspace to a directory where anyone can write.
RUN mkdir /workspace
RUN chmod -R 777 /workspace

RUN groupadd jenkins
RUN useradd -rm -d /home/jenkins -s /bin/bash -g jenkins jenkins
USER jenkins

# Paranoia: make sure another user can write to the home directory too.
RUN chmod -R 777 /home/jenkins
WORKDIR /workspace

CMD /bin/bash
