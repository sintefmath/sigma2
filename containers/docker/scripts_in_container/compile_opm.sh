#!/bin/bash
set -e

if [ -z ${PARALLEL_BUILD_TASKS} ];
then
  PARALLEL_BUILD_TASKS=4
fi

if [[ $# -eq 0 ]];
then
  CLANG_SANITIZE_FLAG=" "
  BUILD_POSTFIX=''
else
  CLANG_SANITIZE_FLAG="-fsanitize=$1 -fsanitize-blacklist=$SCRIPT_DIR/blacklist_${1}.txt -fsanitize-recover=${1} -fsanitize-memory-track-origins=2 -fsanitize-memory-use-after-dtor"
  BUILD_POSTFIX="_${1}"
fi

BUILD_FOLDER="build${BUILD_POSTFIX}"
export SOURCE_CODE_DIR=$(realpath .)
for repo in opm-common opm-material opm-grid opm-models opm-simulators; \
do
  echo "=== Cloning and building module: $repo"
  if [[ ! -d $repo ]];
  then
    git clone https://github.com/OPM/${repo}.git
  fi
  cd $repo
  mkdir -p ${BUILD_FOLDER}
  cd ${BUILD_FOLDER}
  CXX_FLAGS_TO_CMAKE=${MSAN_CFLAGS}
  if [ $repo == "opm-common" ];
  then
    #CXX_FLAGS_TO_CMAKE=''
  fi

  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DUSE_MPI=1 \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-geometry/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-grid/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-istl/${BUILD_FOLDER};" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -Wno-dev .. \
    -DCMAKE_CXX_FLAGS="${CXX_FLAGS_TO_CMAKE}  -stdlib=libc++" \
    -DBUILD_TESTING=OFF \
    -DBUILD_EBOS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS='-stdlib=libc++ -lc++abi' \
    -DBUILD_EXAMPLES=OFF

  make -j${PARALLEL_BUILD_TASKS}
  cd ../..
done
