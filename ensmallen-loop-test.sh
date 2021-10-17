#!/bin/bash

correct=0
counter=0
while [[ $correct == 0 && $counter -lt 14 ]]; do
  ./ensmallen_tests --reporter junit --out report.xml --rng-seed time;
  correct=$?;
  echo $counter
  ((counter = counter + 1))
done
