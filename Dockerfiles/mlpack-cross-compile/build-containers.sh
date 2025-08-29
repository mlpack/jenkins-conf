#!/bin/bash

for f in *.Dockerfile;
do
  arch=`echo $f | sed 's/.Dockerfile$//' | sed 's/^.*-//'`;
  if [ "$arch" = "i386" ]; then
    continue; # skip the 386 one since it builds its own buildroot...
  fi
  echo "Building Docker image mlpack/cross-compile-$arch:latest...";
  docker build --no-cache -f $f -t mlpack/cross-compile-$arch:latest .;
  docker push mlpack/cross-compile-$arch:latest;
done;
