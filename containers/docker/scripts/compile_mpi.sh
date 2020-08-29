#!/bin/bash
set -e

#export CFLAGS='-O2'
#export CXXFLAGS='-O2'
export CFLAGS="-fPIE -fno-omit-frame-pointer -O0 -g"
export CXXFLAGS="-fPIE -fno-omit-frame-pointer -O0 -g"
export LDFLAGS=""

if [ "${OPM_MPI_TYPE}" == "OPENMPI" ];
then
  ##### OPENMPI
  export OMPI_CC=clang
  export CC=clang
  cd ${SOURCE_CODE_DIR}
  if [ ! -d openmpi-4.0.4${BUILD_POSTFIX} ];
  then
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.bz2
    tar xf openmpi-4.0.4.tar.bz2
    mv openmpi-4.0.4 openmpi-4.0.4${BUILD_POSTFIX}
    cd openmpi-4.0.4${BUILD_POSTFIX}
    ./configure --prefix=$INSTALL_PREFIX_SCRATCH --disable-fortran --disable-mpi-fortran
  else
    cd openmpi-4.0.4${BUILD_POSTFIX}
  fi
    make install
    cd ${SOURCE_CODE_DIR}
elif [ "${OPM_MPI_TYPE}" == "MPICH" ];
then
  ##### MPICH
  cd ${SOURCE_CODE_DIR}
  if [ ! -d mpich${BUILD_POSTFIX} ]
  then
    git clone -b v3.3.2 --recursive https://github.com/pmodels/mpich mpich${BUILD_POSTFIX}

    cd mpich${BUILD_POSTFIX}
    # see https://github.com/pmodels/mpich/issues/2643
    PERL_USE_UNSAFE_INC=1 ./autogen.sh
    ./configure --prefix=$INSTALL_PREFIX_SCRATCH --disable-fortran
  else
    cd mpich${BUILD_POSTFIX}
  fi
    make install
    cd ${SOURCE_CODE_DIR}
else
  >&2 echo "Unknown MPI type ${OPM_MPI_TYPE}".
  exti 1
fi
