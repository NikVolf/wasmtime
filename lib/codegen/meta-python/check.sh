#!/bin/bash
set -euo pipefail
topdir=$(dirname "$0")
cd "$topdir"

function runif {
    if type "$1" > /dev/null 2>&1; then
        version=$("$1" --version 2>&1)
        echo "   === $1: $version ==="
        "$@"
    else
        echo "$1 not found"
    fi
}

# Style linting.
runif flake8 .

# Type checking.
# Disable mypy checking on osx on travis for now, since pip installs mypy into
# a directory which is not in the PATH.
if [ "$TRAVIS_OS_NAME" != "osx" ]; then
    runif mypy --py2 build.py
fi

# Python unit tests.
runif python2.7 -m unittest discover

# Then run the unit tests again with Python 3.
# We get deprecation warnings about assertRaisesRegexp which was renamed in
# Python 3, but there doesn't seem to be an easy workaround.
runif python3 -Wignore:Deprecation -m unittest discover