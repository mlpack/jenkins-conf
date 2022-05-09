#!/usr/bin/env python

# Get the test cases given the modified files, the CMakeLists file that
# contains the test files and the path to the tests.
#
# parse_tests.py filenames.txt path/to/CMakeLists.txt path/to/tests

import sys
import re

# Files that should not trigger the memory check.
includeWhiteList = ["core.hpp"]
cmakeFile = sys.argv[2]
testFilePath = sys.argv[3]

# Clean up the test file path.
if not testFilePath.endswith('/'):
  testFilePath = testFilePath + '/'

# Read in the changed files line by line.
with open(sys.argv[1], 'r') as file:
  data = file.readlines()

data = [x.strip() for x in data]
if len(data) <= 0:
  exit(0)

# Clean the changed files: remove the path.
changedFiles = []
for x in data:
  if x.find('/') != -1:
    changedFiles.append(x.rsplit('/', 1)[-1])
  else:
    changedFiles.append(x)

# Clean the changed files: usally we include the header file, so change the file
# ending if only the implementation is changed.
for x in range(0, len(changedFiles)):
  file = changedFiles[x]

  if "_impl" in file:
    changedFiles.append(file.replace("_impl", ""))
    changedFiles.append(file.replace("_impl.hpp", "_main.cpp"))

  if ".cpp" in file:
    changedFiles.append(file.replace(".cpp", ".hpp"))

    if "main.cpp" not in file:
      changedFiles.append(file.replace(".cpp", "_main.cpp"))

changedFiles = list(set(changedFiles))

with open(cmakeFile, 'r') as file:
  data = file.readlines()
data = [x.strip() for x in data]

testSuites = []

# Iterate through all test files and extract includes, test suite name and test
# cases.
for line in data:
  start = line.find('.cpp')
  if start != -1:
    try:
      with open(testFilePath + line, 'r') as file:
        testData = file.readlines()
      testData = [x.strip() for x in testData]
    except:
      continue

    includes = [];
    testCases = [];
    for testLine in testData:
      testCaseRegex = re.search('TEST_CASE\((.*)\)', testLine)

      includeRegex = re.search('#include <(.*)>', testLine)

      if testCaseRegex != None:
        testCases.append(testCaseRegex.group(1).split(",")[0])

      if includeRegex != None:

        # Remove header files that are whitelisted.
        skip = False;
        for include in includeWhiteList:
          if include in includeRegex.group(1):
            skip = True;
            break;

        if not skip:
          includes.append(includeRegex.group(1))

    # Assemble the test cases that should be checked.
    includes.append(line)
    for x in changedFiles:
      if next((s for s in includes if x in s), None) != None:
        for y in testCases:
          testSuites.append(y)

          break;

for x in list(set(testSuites)):
  print(x)
