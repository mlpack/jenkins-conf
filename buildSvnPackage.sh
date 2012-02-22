#!/bin/bash

# Build the package specified in the argument

mkdir -p tarballs
rm build-area/*.*
cd $1/
svn-buildpackage --svn-builder "debuild -us -uc" --svn-non-interactive --svn-download-orig --svn-dont-purge --svn-rm-prev-dir
