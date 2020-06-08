#!/bin/bash
set -e

for repo in opm-common opm-material opm-grid opm-models opm-simulators; \
do
  echo "=== Cloning and building module: $repo"
  git clone https://github.com/OPM/${repo}.git
  cd $repo
  mkdir build
  cd build
  # simple patch
  if [ $repo == "opm-grid" ];
  then
    sed -i 's/scatter\(tmp\.data\(\), logical_cartesian_size_\.data\(\), 3, 0\)/broadcast\(logical_cartesian_size_\.data\(\), 3, 0\)/g' ../opm/grid/cpgrid/processEclipseFormat.cpp
    sed -i 's/scatter\(logical_cartesian_size_\.data\(\), logical_cartesian_size_\.data\(\), 3, 0\)/broadcast\(logical_cartesian_size_\.data\(\), 3, 0\)/g' ../opm/grid/cpgrid/processEclipseFormat.cpp
  fi

  if [ -z $OPM_CLANG_SANITIZE ];
  then
    CLANG_SANITIZE_FLAG=" "
  else
    CLANG_SANITIZE_FLAG="-fsanitize=${OPM_CLANG_SANITIZE} "
  fi
  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DUSE_MPI=1 \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/build;${SOURCE_CODE_DIR}/dune-geometry/build;${SOURCE_CODE_DIR}/dune-grid/build;${SOURCE_CODE_DIR}/dune-istl/build;" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -Wno-dev .. \
    -DCMAKE_CXX_FLAGS=${CLANG_SANITIZE_FLAG}
  make -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
