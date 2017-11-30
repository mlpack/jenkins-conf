#!/usr/bin/env python

# Remove the 'Message' block from the given xml file.
import sys

with open(sys.argv[1], 'r') as file:
  data = file.read()
  while 1:
    start = data.find('<Message')
    if start != -1:
      end = data.find('</Message>')
      data = data.replace(data[start:end+10], '')
    else:
      break
print(data)
