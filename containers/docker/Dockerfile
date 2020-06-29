FROM ubuntu:20.04

# GENERAL BUILD SETUP
ARG PARALLEL_BUILD_TASKS=4
ENV CC=clang
ENV CXX=clang++


ENV CMAKE_BUILD_TYPE=RelWithDebInfo
# This is where the source code of DUNE and OPM will be stored.
# so you will get folders
#   ${SOURCE_CODE_DIR}/opm-common
#   ${SOURCE_CODE_DIR}/opm-simulators
#   ${SOURCE_CODE_DIR}/dune-common
#   ...
ENV SOURCE_CODE_DIR /source_code
ENV SCRIPT_DIR /scripts/
# Used to store OPM-DATA
ENV DATA_DIR /data
# Install location of boost and trilinos
ENV INSTALL_PREFIX /usr/local

# VERSIONS

## BOOST
ENV BOOST_MAJOR_VERSION 1
ENV BOOST_MINOR_VERSION 73
ENV BOOST_RELEASE_VERSION 0

## Trilinos
ENV TRILINOS_MAJOR_VERSION 12
ENV TRILINOS_MINOR_VERSION 18
ENV TRILINOS_RELEASE_VERSION 1

#DUNE
ENV DUNE_MAJOR_VERSION 2
ENV DUNE_MINOR_VERSION 7

# MPI
ARG OPM_MPI_TYPE="MPICH"


RUN mkdir -p ${SOURCE_CODE_DIR}
#
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y g++ gcc build-essential clang wget automake cmake \
      git gfortran libopenblas-dev libsuitesparse-dev python3-all-dev \
      python3-numpy software-properties-common libomp-dev m4 unzip curl libtool autoconf \
        libatomic1 pkg-config libc++-dev libc++abi-dev \
      && ln -s /usr/bin/llvm-symbolizer-3.8 /usr/bin/llvm-symbolizer \
      && rm -rf /var/lib/apt/lists/*


# From https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-c/blob/master/.github/msan-tester.Dockerfile
# and https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo
RUN cd ${SOURCE_CODE_DIR} && \
  git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-10.0.0 \
      	&& cd llvm-project \
      	&& cp -r libcxx llvm/projects/ \
      	&& cp -r libcxxabi llvm/projects/ \
      	&& mkdir ${SOURCE_CODE_DIR}/libcxx_msan \
      	&& cd ${SOURCE_CODE_DIR}/libcxx_msan \
      	&& cmake ../llvm-project/llvm -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_C_COMPILER=clang \
          -DCMAKE_C_FLAGS='-fPIC' \
          -DCMAKE_CXX_FLAGS='-fPIC -stdlib=libc++ -lc++abi' \
          -DCMAKE_SHARED_LINKER_FLAGS='-stdlib=libc++ -lc++abi' \
          -DCMAKE_EXE_LINKER_FLAGS='-stdlib=libc++ -lc++abi' \
          -DCMAKE_CXX_COMPILER=clang++ \
          -DLLVM_USE_SANITIZER=Memory \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      	&& make cxx -j4 \
        && make install \
      	&& rm -rf ${SOURCE_CODE_DIR}/llvm-project

# Important for sanitizers
ARG CLANG_SANITIZER=address
ENV CFLAGS="-fno-omit-frame-pointer -O0 -g -fsanitize=${CLANG_SANITZER}"
ENV CXXFLAGS="-fno-omit-frame-pointer -O0 -g -fsanitize=${CLANG_SANITZER}"
ENV LDFLAGS="-fsanitize=${CLANG_SANITIZER}"
ENV MSAN_CFLAGS="-fsanitize-recover=memory -fsanitize=memory -stdlib=libc++ -L${INSTALL_PREFIX}/lib -lc++abi -I${SOURCE_CODE_DIR}libcxx_msan/include -I${SOURCE_CODE_DIR}libcxx_msan/include/c++/v1"


###### MPI
COPY scripts_in_container/compile_mpi.sh ${SOURCE_CODE_DIR}/
RUN cd ${SOURCE_CODE_DIR} && \
  bash compile_mpi.sh


###### BOOST
RUN cd ${SOURCE_CODE_DIR} &&\
    git clone --recursive --branch boost-${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_RELEASE_VERSION} https://github.com/boostorg/boost  --single-branch && \
    cd boost && \
    ./bootstrap.sh --with-python=$(which python3) --with-libraries=python,program_options,filesystem,system,regex,thread,chrono,date_time,log,test --prefix=$INSTALL_PREFIX && \
    ./b2  --toolset=$CC cxxflags="${MSAN_CFLAGS} -I${INSTALL_PREFIX}/include" linkflags="-fsanitize=memory -stdlib=libc++ -L${INSTALL_PREFIX}/lib" --threading=multi install && \
    cd ${SOURCE_CODE_DIR} && \
    rm -rf boost*

##### TRILINOS
RUN cd ${SOURCE_CODE_DIR} && \
  git clone -b trilinos-release-${TRILINOS_MAJOR_VERSION}-${TRILINOS_MINOR_VERSION}-${TRILINOS_RELEASE_VERSION} https://github.com/trilinos/Trilinos.git && \
  cd Trilinos && \
  mkdir build && \
  cd build && \
  cmake \
    -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -D TPL_ENABLE_MPI:BOOL=ON \
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_Zoltan:BOOL=ON \
    -D Trilinos_ENABLE_Fortran:BOOL=OFF \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_C_FLAGS=${MSAN_CFLAGS} \
    -DCMAKE_CXX_FLAGS=${MSAN_CFLAGS} \
    -Wno-dev \
    ../ &&\
  make -j ${PARALLEL_BUILD_TASKS} && \
  make install && \
  cd ${SOURCE_CODE_DIR} && \
  rm -rf Trilinos

##### OPM-DATA
RUN mkdir -p $DATA_DIR && \
  cd $DATA_DIR && \
  git clone https://github.com/OPM/opm-data

RUN mkdir -p ${DATA_DIR}/scratch

WORKDIR ${DATA_DIR}/scratch


##### SCRIPTS
RUN mkdir -p ${SCRIPT_DIR}
COPY scripts_in_container/compile_dune.sh ${SCRIPT_DIR}/
COPY scripts_in_container/compile_opm.sh ${SCRIPT_DIR}/
COPY scripts_in_container/run_simulator.sh ${SCRIPT_DIR}/
COPY scripts_in_container/compile.sh ${SCRIPT_DIR}/
COPY scripts_in_container/entrypoint.sh ${SCRIPT_DIR}/
COPY scripts_in_container/blacklist_*.txt ${SCRIPT_DIR}/
RUN chmod -R a+rwX ${SCRIPT_DIR}


##### Make read-write for everyone
RUN chmod -R a+rwX ${DATA_DIR} && \
  chmod -R a+rwX ${SOURCE_CODE_DIR}


# see https://stackoverflow.com/questions/49133234/docker-entrypoint-with-env-variable-and-optional-arguments
ENTRYPOINT ["bash", "/scripts/entrypoint.sh"]
