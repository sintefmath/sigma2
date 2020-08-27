#/bin/bash

##### TRILINOS
cd ${SOURCE_CODE_DIR}
git clone -b trilinos-release-${TRILINOS_MAJOR_VERSION}-${TRILINOS_MINOR_VERSION}-${TRILINOS_RELEASE_VERSION} https://github.com/trilinos/Trilinos.git
cd Trilinos
mkdir build
cd build
cmake \
    -D CMAKE_INSTALL_PREFIX="$INSTALL_PREFIX;$INSTALL_PREFIX_SCRATCH" \
    -D TPL_ENABLE_MPI:BOOL=ON \
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_Zoltan:BOOL=ON \
    -D Trilinos_ENABLE_Fortran:BOOL=OFF \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_C_FLAGS="${CLANG_SANITIZE_FLAG} ${MSAN_CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CLANG_SANITIZE_FLAG} ${MSAN_CFLAGS}" \
    -Wno-dev \
    ../
make -j ${PARALLEL_BUILD_TASKS}
make install
cd ${SOURCE_CODE_DIR}
rm -rf Trilinos
