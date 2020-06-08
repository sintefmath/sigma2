#!/bin/bash
set -e

if [-z ${PARALLEL_BUILD_TASKS} ];
then
  PARALLEL_BUILD_TASKS=4
fi

if [[ $# -eq 0 ]];
then
  CLANG_SANITIZE_FLAG=" "
else
  CLANG_SANITIZE_FLAG="-fsanitize=${OPM_CLANG_SANITIZE} "
fi


for repo in opm-common opm-material opm-grid opm-models opm-simulators; \
do
  echo "=== Cloning and building module: $repo"
  if [[ ! -d $repo ]];
  then
    git clone https://github.com/OPM/${repo}.git
  fi
  cd $repo
  mkdir -p build
  cd build

  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DUSE_MPI=1 \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/build;${SOURCE_CODE_DIR}/dune-geometry/build;${SOURCE_CODE_DIR}/dune-grid/build;${SOURCE_CODE_DIR}/dune-istl/build;" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -Wno-dev .. \
    -DCMAKE_CXX_FLAGS=${CLANG_SANITIZE_FLAG}
  make -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
