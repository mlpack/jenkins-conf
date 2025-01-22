#!/bin/bash
#
# Run Google's cpplint over the codebase and provide output in junit format.
#
# The given arguments are the src root and the reports directory e.g.:
# ./lint.sh --root . --reports reports/cpplint.junit.xml

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -r|--root)
    root="$2"
    shift # past argument
    ;;
    -e|--reports)
    reports="$2"
    shift # past argument
    ;;
    -d|--dir)
    dir="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

linter="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

# Change to source directory.
cd "$root"

# Create a simple python venv to install cpplint.
# We specifically use 1.6.1 because 2.0.0 and newer have big changes.
python3 -m venv lint_venv/
source lint_venv/bin/activate
pip3 install cpplint

# Get all files for the style check and exclude external files and run
# cpplint and convert the output.
find "$dir" \
    -not -path "*src/mlpack/core/arma_extend/*" \
    -not -path "*src/mlpack/tests/catch.hpp" \
    -not -path "*src/mlpack/bindings/cli/third_party/CLI/CLI11.hpp" \
    -not -path "*src/mlpack/core/cereal/*.hpp" \
    -not -path "*tests/catch.hpp" \
    -not -path "*tests/ann/not_adapted/*.cpp" \
    -iname '*.[hc]pp' -type f -print0 | \
    xargs -0 cpplint --extensions=hpp,cpp --output=junit --filter=\
-legal/copyright,\
-build/c++11,\
-build/header_guard,\
-build/include,\
-build/include_order,\
-build/include_subdir,\
-build/include_what_you_use,\
-build/namespaces_literals,\
-build/namespaces,\
-readability/casting,\
-readability/inheritance,\
-readability/todo,\
-readability/multiline_comment,\
-runtime/explicit,\
-runtime/int,\
-runtime/references,\
-whitespace/braces,\
-whitespace/comments,\
-whitespace/newline,\
-whitespace/indent_namespace 2> "$reports";
# Output goes to stderr, so redirect that to the output file.

rm -rf lint_venv/ # Clean up venv.

# Restore directory.
cd "$cwd"
