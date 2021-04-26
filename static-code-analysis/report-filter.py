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
             ("*", "is allocated on the heap and never freed. In function mlpackMain."),
             ("*", "has already been deleted by delete."),
             ("fastmks_impl.hpp", "Leaking memory. Tree is allocated on the heap and never freed. In function Train."),
             ("*", "Use after free. Object is used after it may already have been freed with delete."),
             ("io_util.hpp", "Leaking memory. T is allocated on the heap and never freed. In function SetParamPtr."),
             ("load_csv.hpp", "Missing check is_open on std::ifstream before calling seekg on it."),
             ("x_tree_split_impl.hpp", "This division may result in a division by zero error because a 0 value flows as a possible divisor."),
             ("silhouette_score_impl.hpp", "The value written to &amp;interClusterDistance (type double) is never used."),
             ("stb_image.h", "*"),
             ("stb_image_write.h", "*"),
             ("rectangle_tree_impl.hpp", "pointer `parent` last assigned on line 60 could be null and is dereferenced by call to `RPlusPlusTreeAuxiliaryInformation` at line 71, column 5."),
             ("rectangle_tree_impl.hpp", "pointer `parent` last assigned on line 101 could be null and is dereferenced by call to `RPlusPlusTreeAuxiliaryInformation` at line 112, column 5."),
             ("svd_incomplete_incremental_learning.hpp", "The value written to &amp;val (type double) is never used."),
             ("approx_kfn_main.cpp", "The value read from referenceSet.n_cols was never initialized."),
             ("bayesian_linear_regression.cpp", "The value written to &amp;deltaAlpha (type double) is never used."),
             ("hmm_impl.hpp", "The value written to &amp;randValue (type double) is never used."),
             ("hoeffding_tree_impl.hpp", "The value read from childMajorities.n_elem was never initialized."),
             ("hoeffding_tree_main.cpp", "The value read from labels.n_elem was never initialized."),
             ("linear_svm_main.cpp", "The value read from trainingSet.n_cols was never initialized."),
             ("linear_svm_main.cpp", "The value read from trainingSet.n_rows was never initialized."),
             ("lmnn_function_impl.hpp", "The value written to &amp;bp (type unsigned long) is never used."),
             ("logistic_regression_main.cpp", "The value read from regressors.n_rows was never initialized."),
             ("logistic_regression_main.cpp", "The value read from regressors.n_cols was never initialized."),
             ("lsh_main.cpp", "The value read from neighbors.n_rows was never initialized."),
             ("lsh_main.cpp", "The value read from neighbors.n_cols was never initialized."),
             ("neighbor_search_rules_impl.hpp", "The value written to &amp;baseCase (type double) is never used."),
             ("perceptron_impl.hpp", "The value written to &amp;wip (type mlpack::perceptron::ZeroInitialization*) is never used."),
             ("perceptron_impl.hpp", "The value written to &amp;wip (type mlpack::perceptron::ZeroInitialization*) is never used."),
             ("ann_layer_test.cpp", "The value read from cellCalc.n_cols was never initialized."),
             ("ann_layer_test.cpp", "The value read from cellCalc.n_rows was never initialized."),
             ("block_krylov_svd_test.cpp", "The value written to &amp;rSVDB (type mlpack::svd::RandomizedBlockKrylovSVD*) is never used."),
             ("cli_binding_test.cpp", "The value written to &amp;"),
             ("gmm_test.cpp", "The value written to &amp;minDiff (type double) is never used."),
             ("io_test.cpp", "The value written to"),
             ("io_test.cpp", "Initializer of anonymous_namespace"),
             ("kde_test.cpp", "The value read from query.n_cols was never initialized."),
             ("nystroem_method_test.cpp", "The value written to &amp;lk (type mlpack::kernel::LinearKernel*) is never used."),
             ("kernel_test.cpp", "The value written to &amp;lk (type mlpack::kernel::LinearKernel*) is never used."),
             ("kmeans_test.cpp", "The value written to &amp;k (type KMeansPlusPlusInitialization*) is never used."),
             ("ksinit_test.cpp", "The value written to &amp;validationDataSize (type unsigned long) is never used."),
             ("lsh_test.cpp", "The value read from fail was never initialized."),
             ("metric_test.cpp", "The value written to"),
             ("python_binding_test.cpp", "The value written to"),
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
