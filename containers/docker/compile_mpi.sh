#!/bin/bash
set -e

if [ "${OPM_MPI_TYPE}" == "OPENMPI" ];
then
  ##### OPENMPI
  cd ${SOURCE_CODE_DIR}
  wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.3.tar.bz2
  tar xf openmpi-4.0.3.tar.bz2
  cd openmpi-4.0.3
  ./configure --prefix=$INSTALL_PREFIX --disable-fortran --disable-mpi-fortran
  make install
  cd ${SOURCE_CODE_DIR}
  rm -rf openmpi-4.0.3*

elif [ "${OPM_MPI_TYPE}" == "MPICH" ];
then
  ##### MPICH
  cd ${SOURCE_CODE_DIR}
  wget https://github.com/pmodels/mpich/archive/v3.1.4.tar.gz
  DEBIAN_FRONTEND=noninteractive apt-get install -y libtool autoconf
  tar xf v3.1.4.tar.gz
  cd mpich-3.1.4
  ./autogen.sh
  ./configure --prefix=$INSTALL_PREFIX --disable-fortran
  make install
  cd ${SOURCE_CODE_DIR}
  rm -rf mpich-*;
else
  >&2 echo "Unknown MPI type ${OPM_MPI_TYPE}".
  exti 1
fi
