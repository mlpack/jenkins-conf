#!/usr/bin/env python

# Convert output from Google's cpplint.py to the cppcheck XML format for
# consumption by the Jenkins cppcheck plugin.

# Reads from stdin and writes to stderr (to mimic cppcheck)

import sys
import re
import xml.sax.saxutils

import argparse

whitelist = [("logistic_regression_main.cpp", "pointer was used after the memory was released"),
             ("logistic_regression_main.cpp", "operator is called twice for deallocation of the same memory space")]

issues = []

def check_whitelist(line):
    for w in whitelist:
        if w[0] in line and w[1] in line:
            return True

    return False

def check_issues(report, file, lineno):
    for line in report:
        if file in line and lineno in line:
            return True

    return False

def parse(reportFile, reportFileA, reportFileB):
    # Read filenames.
    with open(reportFileA) as f: reportA = [line.rstrip('\n') for line in f]

    with open(reportFileB) as f: reportB = [line.rstrip('\n') for line in f]

    with open(reportFile, "w") as f:
        # Write header.
        f.write('''<?xml version="1.0" encoding="UTF-8"?>\n''')
        f.write('''<results version="2">\n''')
        f.write('''<cppcheck version="1.66">\n''')
        f.write('''<errors>\n''')

        # Flush all issues from the reference report to the new report file.
        for line in reportA:
            if ("<error" in line and "<errors>" not in line) or "<location" in line or "</error>" in line:
                f.write(line + "\n")

        # Add issues from the second report file to the new report file that
        # aren't in the reference report.
        i = 0
        while i < len(reportB):
            if "<location" in reportB[i]:
                line = reportB[i]

                ps = line.find('file="')
                pe = line.find('"', ps + 6)
                file = line[ps:pe + 1]

                ps = line.find('line="')
                pe = line.find('"', ps + 6)
                lineno = line[ps:pe + 1]

                if check_issues(reportA, file, lineno) == False:
                        f.write(reportB[i - 1] + "\n")
                        f.write(reportB[i]  + "\n")
                        f.write(reportB[i + 1]  + "\n")

            i += 1

        # Write footer.
        f.write('''</errors>\n''')
        f.write('''</cppcheck>\n''')
        f.write('''</results>\n''')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="""Cleans the static code analysis report.""")
    parser.add_argument('-r','--report', help='Report file name.', required=True)
    parser.add_argument('-e','--reportA', help='Report file name A.', required=True)
    parser.add_argument('-p','--reportB', help='Report file name B.', required=True)

    args = parser.parse_args()
    if args:
        parse(args.report, args.reportA, args.reportB)
