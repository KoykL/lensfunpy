#!/bin/bash
set -e -x

source travis/travis_retry.sh

# Build wheel
git clone https://github.com/MacPython/terryfy.git
set +x # reduce noise
source terryfy/travis_tools.sh
travis_retry get_python_environment macports $PYTHON_VERSION venv
set -x
travis_retry pip install numpy==$NUMPY_VERSION cython wheel delocate
pip freeze
brew update
brew install glib
brew link --force gettext
export CC=clang
export CXX=clang++
export CFLAGS="-arch x86_64"
export CXXFLAGS=$CFLAGS
export LDFLAGS=$CFLAGS
export ARCHFLAGS=$CFLAGS
python setup.py bdist_wheel
delocate-listdeps --all dist/*.whl # lists library dependencies
delocate-wheel --require-archs=x86_64 dist/*.whl # copies library dependencies into wheel
delocate-listdeps --all dist/*.whl # verify

# Install lensfunpy
pip install dist/*.whl

# Test installed lensfunpy
travis_retry pip install numpy -U # scipy should trigger an update, but that doesn't happen
travis_retry pip install -r dev-requirements.txt
# make sure it's working without any required libraries installed
brew uninstall --ignore-dependencies glib
mkdir tmp_for_test
pushd tmp_for_test
nosetests --verbosity=3 --nocapture ../test
popd

# deploy if git tag
travis/deploy_pypi.sh