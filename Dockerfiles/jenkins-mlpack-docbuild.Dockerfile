# Dockerfile to build docs for mlpack.
FROM debian:unstable

LABEL maintainer="ryan@ratml.org"

## For apt to be noninteractive.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -qq && \
    apt-get upgrade -yy && \
    apt-get dist-upgrade -yy && \
    apt-get install -yy kramdown ruby-kramdown-parser-gfm ruby-rouge tidy w3c-linkchecker curl bzip2 gzip linkchecker sqlite3 ccache && \
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
