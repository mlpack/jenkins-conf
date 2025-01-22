# Dockerfile to build docs for mlpack.
FROM debian:unstable

LABEL maintainer="ryan@ratml.org"

## For apt to be noninteractive.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -yy kramdown ruby-kramdown-parser-gfm ruby-rouge tidy w3c-linkchecker curl linkchecker sqlite3 ccache && \
    apt-get install -yy locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    /usr/sbin/locale-gen && \
    apt-get install -yy g++ libopenblas-dev libarmadillo-dev libeigen3-dev libxtensor-dev libensmallen-dev libstb-dev libcereal-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup environment.
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /home/jenkins
# The actual build may run as any random uid, including whatever the system uid
# for jenkins is.
RUN chmod 777 /home/jenkins
WORKDIR /home/jenkins

CMD /bin/bash
