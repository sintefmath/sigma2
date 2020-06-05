#!/bin/bash
set -e

for repo in dune-common dune-geometry dune-grid dune-istl;
do
  echo "=== Cloning and building module: $repo"
  git clone -b releases/${DUNE_MAJOR_VERSION}.${DUNE_MINOR_VERSION} https://gitlab.dune-project.org/core/$repo.git
  cd $repo
  mkdir build
  cd build
  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/build;${SOURCE_CODE_DIR}/dune-geometry/build;${SOURCE_CODE_DIR}/dune-grid/build;${SOURCE_CODE_DIR}/dune-istl/build;" \
    ..
  make -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
