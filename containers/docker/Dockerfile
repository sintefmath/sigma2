FROM ubuntu:20.04

# GENERAL BUILD SETUP
ARG PARALLEL_BUILD_TASKS=4
ARG CC=clang
ARG CXX=clang++
ARG CMAKE_BUILD_TYPE=Release
# This is where the source code of DUNE and OPM will be stored.
# so you will get folders
#   ${SOURCE_CODE_DIR}/opm-common
#   ${SOURCE_CODE_DIR}/opm-simulators
#   ${SOURCE_CODE_DIR}/dune-common
#   ...
ENV SOURCE_CODE_DIR /source_code
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
ENV TRILINOS_MINOR_VERSION 8
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
      python3-numpy software-properties-common libomp-dev m4 unzip curl libtool autoconf



###### MPI
COPY compile_mpi.sh ${SOURCE_CODE_DIR}/
RUN cd ${SOURCE_CODE_DIR} && \
  bash compile_mpi.sh


###### BOOST
RUN cd ${SOURCE_CODE_DIR} &&\
    wget https://dl.bintray.com/boostorg/release/${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_RELEASE_VERSION}/source/boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2 && \
    tar xf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2 &&\
    cd boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION} && \
    ./bootstrap.sh --with-python=$(wich python3) --with-libraries=python,program_options,filesystem,system,regex,thread,chrono,date_time,log,test --prefix=$INSTALL_PREFIX && \
    ./b2  --toolset=$CC --threading=multi install && \
    cd ${SOURCE_CODE_DIR} && \
    rm -rf boost_*

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
    -Wno-dev \
    ../ &&\
  make -j ${PARALLEL_BUILD_TASKS} && \
  make install && \
  cd ${SOURCE_CODE_DIR} && \
  rm -rf Trilinos

##### DUNE
COPY compile_dune.sh ${SOURCE_CODE_DIR}/
RUN cd ${SOURCE_CODE_DIR} && \
  bash compile_dune.sh


##### OPM
COPY compile_opm.sh ${SOURCE_CODE_DIR}/
RUN cd ${SOURCE_CODE_DIR} && \
  bash compile_opm.sh

# ##### ALSVINN
# RUN git clone --recursive https://github.com/alsvinn/alsvinn.git &&\
#    cd alsvinn && \
#    mkdir build && \
#    cd build && \
#    cmake .. -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
#     -DALSVINN_PYTHON_VERSION=3.8 \
#     -DALSVINN_USE_CUDA=OFF \
#     -DALSVINN_BUILD_TESTS=OFF \
#     -DALSVINN_BUILD_DOXYGEN=OFF \
#     -DCMAKE_INSTALL_PREFIX=${ALSVINN_INSTALL_PREFIX} && \
#   make -j ${PARALLEL_BUILD_TASKS} install



##### OPM-DATA
RUN mkdir -p $DATA_DIR && \
  cd $DATA_DIR && \
  git clone https://github.com/OPM/opm-data


RUN mkdir -p ${DATA_DIR}/scratch

WORKDIR ${DATA_DIR}/scratch

##### Make read-write for everyone
RUN chmod -R a+rwX ${DATA_DIR} && \
  chmod -R a+rwX ${SOURCE_CODE_DIR}


COPY "run_simulator.sh" /data/
ENTRYPOINT ["bash", "/data//run_simulator.sh"]
