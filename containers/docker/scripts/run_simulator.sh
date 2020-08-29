#!/bin/bash
set -e
set -o xtrace
export INSTALL_PREFIX_SCRATCH=${INSTALL_PREFIX_SCRATCH_BASE}/${CONTAINER_CLANG_SANITIZER}

export ASAN_OPTIONS=halt_on_error=1

if [[ $# -eq 1 ]];
then
  number_of_processes=1
else
  number_of_processes=$2
fi

mpirun_version_output=$($INSTALL_PREFIX_SCRATCH/bin/mpirun --version)

# MPICH and OpenMPI require different hostfiles...
if [[ $mpirun_version_output == *"Open MPI"* ]];
then
  function run_mpi_with_hosts {
    # Make sure MPI believes we have enough slots
    echo "localhost slots=$number_of_processes" > hostfile
    time $INSTALL_PREFIX_SCRATCH/bin/mpirun --hostfile hostfile "$@"
  }
else
  function run_mpi_with_hosts {
    echo "localhost:$number_of_processes" > hosts
    $INSTALL_PREFIX_SCRATCH/bin/mpirun -f hosts "$@"
  }
fi
if [[ $# -eq 0 ]];
then
  BUILD_POSTFIX=''
else
  BUILD_POSTFIX="_${1}"
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALL_PREFIX}/lib:${INSTALL_PREFIX}/lib64

# Run simulator
run_mpi_with_hosts -np $number_of_processes $SOURCE_CODE_DIR/opm-simulators/build${BUILD_POSTFIX}/bin/flow \
  $DATA_DIR/opm-data/norne/NORNE_ATW2013.DATA \
  --threads-per-process=1 --output-dir=output
