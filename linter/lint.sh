#!/bin/bash
#
# Run Google's cpplint over the codebase and convert convert the output from
# Google's cpplint.py to the cppcheck XML format for consumption by the Jenkins
# cppcheck plugin.
#
# The given arguments are the src root and the reports directory e.g.:
# ./lint.sh --root . --reports reports/cpplint.xml

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
    xargs -0 cpplint --extensions=hpp,cpp --filter=\
-legal/copyright,\
-build/c++11,\
-build/header_guard,\
-build/include_order,\
-build/include_subdir,\
-build/include_what_you_use,\
-build/namespaces_literals,\
-build/namespaces,\
-readability/casting,\
-readability/inheritance,\
-readability/todo,\
-runtime/explicit,\
-runtime/int,\
-runtime/references,\
-whitespace/braces,\
-whitespace/comments,\
-whitespace/newline\
    2>&1 | \
grep -v 'Do not include \.cpp files' |\
grep -v 'Consider using rand_r' |\
grep -v 'Missing spaces around <' |\
python3 "$linter"/cpplint_cppcheckxml.py 2> "$reports"

rm -rf lint_venv/ # Clean up venv.

# Restore directory.
cd "$cwd"
