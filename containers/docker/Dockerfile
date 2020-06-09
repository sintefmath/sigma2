FROM ubuntu:20.04

# GENERAL BUILD SETUP
ARG PARALLEL_BUILD_TASKS=4
ARG CC=clang
ARG CXX=clang++
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
# Install location of Alsvinn
ENV ALSVINN_INSTALL_PREFIX /alsvinn



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

RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y g++ gcc build-essential clang wget automake cmake \
      git gfortran libopenblas-dev libsuitesparse-dev python3-all-dev \
      python3-numpy software-properties-common libomp-dev m4 unzip curl libtool autoconf \
      libc++-dev libc++abi-dev



###### MPI
COPY scripts_in_container/compile_mpi.sh ${SOURCE_CODE_DIR}/
RUN cd ${SOURCE_CODE_DIR} && \
  bash compile_mpi.sh


###### BOOST
RUN cd ${SOURCE_CODE_DIR} &&\
    git clone --recursive --branch boost-${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_RELEASE_VERSION} https://github.com/boostorg/boost  --single-branch && \
    cd boost && \
    ./bootstrap.sh --with-python=$(which python3) --with-libraries=python,program_options,filesystem,system,regex,thread,chrono,date_time,log,test --prefix=$INSTALL_PREFIX && \
    ./b2  --toolset=$CC cxxflags="-std=c++1y -stdlib=libc++" linkflags="-stdlib=libc++" --threading=multi install && \
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
    -DCMAKE_C_FLAGS='-fPIE' \
    -DCMAKE_CXX_FLAGS='-fPIE' \
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
RUN chmod -R a+rwX ${SCRIPT_DIR}


##### Make read-write for everyone
RUN chmod -R a+rwX ${DATA_DIR} && \
  chmod -R a+rwX ${SOURCE_CODE_DIR}


# see https://stackoverflow.com/questions/49133234/docker-entrypoint-with-env-variable-and-optional-arguments
ENTRYPOINT ["bash", "/scripts/entrypoint.sh"]
