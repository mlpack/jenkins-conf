#!/usr/bin/env python

import sys
import re
import xml.sax.saxutils

import argparse

whitelist = [("*", "There are identical sub-expressions to the left and to the right of the &apos;%&apos; operator: gradient % gradient"),
             ("*", "There are identical sub-expressions to the left and to the right of the &apos;%&apos; operator: dx % dx"),
             ("proximal_impl.hpp", "The value written to &amp;theta (type double) is never used."),
             ("lbfgs_impl.hpp", "The value written to &amp;scalingFactor (type double) is never used."),
             ("lbfgs_impl.hpp", "The value written to &amp;prevFunctionValue (type double) is never used."),
             ("lbfgs_impl.hpp", "The value written to &amp;prevFunctionValue (type float) is never used."),
             ("sa_impl.hpp", "The value written to &amp;oldEnergy (type double) is never used."),
             ("sa_impl.hpp", "The value written to &amp;oldEnergy (type float) is never used."),
             ("*", "Duplicate expressions on both sides of a binary operator is probably a mistake."),
             ("spalera_sgd_impl.hpp", "The value written to &amp;currentObjective (type double) is never used."),
             ("spalera_sgd_impl.hpp", "The value written to &amp;currentObjective (type float) is never used."),
             ("scd_test.cpp", "The value written to &amp;descentPolicy (type ens::GreedyDescent*) is never used."),
             ("scd_test.cpp", "The value written to &amp;descentPolicy (type ens::CyclicDescent*) is never used."),
             ("*", "There are identical sub-expressions to the left and to the right of the &apos;%&apos; operator: g % g"),
             ("catch.hpp", "*")]

def check_whitelist_issue(line):
    for w in whitelist:
        if w[0] in line and w[1] in line:
            return True
        elif w[0] == '*' and w[1] in line:
            return True
        elif w[0] in line and w[1] == '*':
            return True
    return False

def check_filename(line, filenames):
    for file in filenames:
        if file in line:
            return True
    return False

def parse(reportFile):
    # Read report.
    with open(reportFile) as f: results = [line.rstrip('\n') for line in f]

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

                if check_whitelist_issue(line) == False:
                    f.write(results[i] + "\n")
                    f.write(results[i + 1] + "\n")
                    f.write(results[i + 2] + "\n")
            i += 1

        # Write footer.
        f.write('''</errors>\n''')
        f.write('''</cppcheck>\n''')
        f.write('''</results>\n''')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="""Cleans the static code analysis report.""")
    parser.add_argument('-r','--report', help='Report file name.', required=True)

    args = parser.parse_args()
    if args:
        parse(args.report)
