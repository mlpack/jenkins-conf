#!/usr/bin/env python

# Get the test cases given the modified files and the CMakeLists file that
# contains the test files.
#
# parse_ensmallen_tests.py filenames.txt path/to/CMakeLists.txt

import sys
import os

filenamesFile = sys.argv[1]
cmakeFile = sys.argv[2]
testPath = os.path.dirname(cmakeFile)

# Read changed files.
changedFiles = []
with open(filenamesFile, 'r') as f:
  changedFiles = f.readlines()

# Remove 'ensmallen.hpp' from the list of changed files, so
# we don't trigger all tests.
changedFiles = list(filter(lambda i: 'ensmallen.hpp' not in i, changedFiles))

# Clean the changed files: remove the path
# and create trigger words.
triggerWords = []
for i, changedFile in enumerate(changedFiles):
  name = os.path.basename(changedFile.strip())
  name = os.path.splitext(name)[0]

  name = name.lower()

  name = name.replace('_impl', '')
  if name not in triggerWords:
    triggerWords.append(name)

  name = name.replace('_', '')
  if name not in triggerWords:
    triggerWords.append(name)

with open(cmakeFile, 'r') as f:
  content = f.readlines()

# Compile a list of test files.
testFiles = []
for line in content:
  if '.cpp' in line and 'main.cpp' not in line:
    testFiles.append(line.strip())

# Iterate over all test files and check if a keyword exists in the file.
testSuites = []
for testFile in testFiles:
  with open(testPath + '/' + testFile, 'r') as f:
    content = f.read()

  for word in triggerWords:
    if word.lower() in content.lower():

      # Extract the test suite name.
      start = content.find('TEST_CASE(')
      stop = content.find(')', start)

      line = content[start:stop]
      start = line.find('[') + 1
      stop = line.find(']')

      testSuite = line[start:stop]
      if testSuite not in testSuites:
        testSuites.append(testSuite)

for testSuite in testSuites:
  print('"[' + testSuite + ']"')
