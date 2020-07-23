#!/usr/bin/env python

# Convert output from Google's cpplint.py to the cppcheck XML format for
# consumption by the Jenkins cppcheck plugin.

# Reads from stdin and writes to stderr (to mimic cppcheck)

import sys
import re
import xml.sax.saxutils

import argparse

whitelist = [("logistic_regression_main.cpp", "pointer was used after the memory was released"),
             ("logistic_regression_main.cpp", "operator is called twice for deallocation of the same memory space"),
             ("drusilla_select_impl.hpp", "syntaxError"),
             ("em_fit_impl.hpp", "syntax error"),
             ("lmnn_function_impl.hpp", "syntax error"),
             ("best_binary_numeric_split_impl.hpp", "syntax error"),
             ("catch.hpp", "syntax error"),
             ("*", "Such expressions using the &apos;,&apos; operator are dangerous. Make sure the expression is correct."),
             ("ra_search_impl.hpp", "syntax error")]

def check_whitelist_issue(line):
    for w in whitelist:
        if w[0] in line and w[1] in line:
            return True
        elif w[0] == '*' and w[1] in line:
            return True
    return False

def check_filename(line, filenames):
    for file in filenames:
        if file in line:
            return True
    return False

def parse(filenamesFile, reportFile):
    # Read tasklist file.
    with open(reportFile) as f: results = [line.rstrip('\n') for line in f]

    # Read filenames.
    with open(filenamesFile) as f: names = [line.rstrip('\n') for line in f]


    with open(reportFile + "n", "w") as f:
        # Write header.
        f.write('''<?xml version="1.0" encoding="UTF-8"?>\n''')
        f.write('''<results version="2">\n''')
        f.write('''<cppcheck version="1.66">\n''')
        f.write('''<errors>\n''')

        i = 0
        while i < len(results):
            if "<error " in results[i]:
                errorLine = results[i]
                locationLine = results[i + 1]

                line = errorLine + " " + locationLine

                if check_whitelist_issue(line) == False and check_filename(line, names) == True:
                    f.write(results[i] + "\n")
                    f.write(results[i + 1] + "\n")
                    f.write(results[i + 2] + "\n")
            i += 1

        # Write footer.
        f.write('''</errors>\n''')
        f.write('''</results>\n''')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="""Cleans the static code analysis report.""")
    parser.add_argument('-f','--filenames', help='File to create a report for.', required=True)
    parser.add_argument('-r','--report', help='Report file name.', required=True)

    args = parser.parse_args()
    if args:
        parse(args.filenames, args.report)
