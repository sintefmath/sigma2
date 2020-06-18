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
  CLANG_SANITIZE_FLAG="-fsanitize=$1 "
  BUILD_POSTFIX="_${1}"
fi
BUILD_FOLDER="build${BUILD_POSTFIX}"
export SOURCE_CODE_DIR=$(realpath .)
for repo in dune-common dune-geometry dune-grid dune-istl;
do
  echo "=== Cloning and building module: $repo"
  if [[ ! -d ${repo} ]]
  then
    git clone -b releases/${DUNE_MAJOR_VERSION}.${DUNE_MINOR_VERSION} https://gitlab.dune-project.org/core/$repo.git
  fi
  cd $repo
  mkdir -p ${BUILD_FOLDER}
  cd ${BUILD_FOLDER}
  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-geometry/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-grid/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-istl/${BUILD_FOLDER};" \
    -DCMAKE_EXE_LINKER_FLAGS='-fsanitize=memory -stdlib=libc++ -lc++abi' \
    -DCMAKE_CXX_FLAGS=${MSAN_CFLAGS} \
    ..
  make -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
