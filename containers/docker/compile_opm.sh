#!/bin/bash
set -e

for repo in opm-common opm-material opm-grid opm-models opm-simulators; \
do
  echo "=== Cloning and building module: $repo"
  git clone https://github.com/OPM/${repo}.git
  cd $repo
  mkdir build
  cd build
  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DUSE_MPI=1 \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/build;${SOURCE_CODE_DIR}/dune-geometry/build;${SOURCE_CODE_DIR}/dune-grid/build;${SOURCE_CODE_DIR}/dune-istl/build;" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -Wno-dev ..
  make -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
