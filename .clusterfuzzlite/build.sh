#!/bin/bash -eu

# ClusterFuzzLite build script.
# Builds Python fuzzers using OSS-Fuzz helper.

python3 -m pip install \
  --no-cache-dir \
  --require-hashes \
  -r .clusterfuzzlite/requirements.txt

# Make the project root visible to PyInstaller so the packaged fuzzer includes
# the production sanitizer module instead of relying on a runtime source path.
export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"

# Build fuzz targets.
for fuzzer in fuzz/fuzz_*.py; do
  compile_python_fuzzer "$fuzzer"
done
