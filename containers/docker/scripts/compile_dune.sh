#!/bin/bash
set -e
if [ -z ${PARALLEL_BUILD_TASKS} ];
then
  PARALLEL_BUILD_TASKS=1
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
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${INSTALL_PREFIX_SCRATCH};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-geometry/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-grid/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-istl/${BUILD_FOLDER};" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=${CONTAINER_CLANG_SANITIZER} -stdlib=libc++ -lc++abi -L${INSTALL_PREFIX}/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=${CONTAINER_CLANG_SANITIZER} -stdlib=libc++ -lc++abi -L${INSTALL_PREFIX}/lib" \
    -DCMAKE_CXX_FLAGS="${CLANG_SANITIZE_FLAG} ${MSAN_CFLAGS} -I${INSTALL_PREFIX}/include" \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_C_COMPILER=${CC} \
    ..
  make VERBOSE=1 -j ${PARALLEL_BUILD_TASKS}
  cd ../..
done
