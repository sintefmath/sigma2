#!/bin/bash
set -e
export ASAN_OPTIONS=halt_on_error=0

if [ -z ${PARALLEL_BUILD_TASKS} ];
then
  PARALLEL_BUILD_TASKS=4
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
  #if [ $repo == "opm-common" ];
  #then
    #CXX_FLAGS_TO_CMAKE=''
  #fi

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_PREFIX}/lib:${INSTALL_PREFIX}/lib64:
  cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DUSE_MPI=1 \
    -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${INSTALL_PREFIX_SCRATCH};${SOURCE_CODE_DIR}/dune-common;${SOURCE_CODE_DIR}/dune-common/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-geometry/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-grid/${BUILD_FOLDER};${SOURCE_CODE_DIR}/dune-istl/${BUILD_FOLDER};" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -Wno-dev .. \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=${CONTAINER_CLANG_SANITIZER} -fsanitize-recover=${CONTAINER_CLANG_SANITIZER} -stdlib=libc++ -lc++abi -L${INSTALL_PREFIX}/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=${CONTAINER_CLANG_SANITIZER} -fsanitize-recover=${CONTAINER_CLANG_SANITIZER} -stdlib=libc++ -lc++abi -L${INSTALL_PREFIX}/lib" \
    -DCMAKE_CXX_FLAGS="${MSAN_CFLAGS} ${CLANG_SANITIZE_FLAG} -I${INSTALL_PREFIX}/include" \
    -DBUILD_TESTING=OFF \
    -DBUILD_EBOS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS='-stdlib=libc++ -lc++abi' \
    -DBUILD_EXAMPLES=OFF

  make -j${PARALLEL_BUILD_TASKS}
  cd ../..
done
