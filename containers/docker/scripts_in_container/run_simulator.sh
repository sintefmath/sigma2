#!/bin/bash
set -e

if [[ $# -eq 1 ]];
then
  number_of_processes=1
else
  number_of_processes=$2
fi

mpirun_version_output=$(mpirun --version)

# MPICH and OpenMPI require different hostfiles...
if [[ $mpirun_version_output == *"Open MPI"* ]];
then
  function run_mpi_with_hosts {
    # Make sure MPI believes we have enough slots
    echo "localhost slots=$number_of_processes" > hostfile
    time mpirun --hostfile hostfile "$@"
  }
else
  function run_mpi_with_hosts {
    echo "localhost:$number_of_processes" > hosts
    mpirun -f hosts "$@"
  }
fi
if [[ $# -eq 0 ]];
then
  BUILD_POSTFIX=''
else
  BUILD_POSTFIX="_${1}"
fi


# Run simulator
run_mpi_with_hosts -np $number_of_processes $SOURCE_CODE_DIR/opm-simulators/build${BUILD_POSTFIX}/bin/flow \
  $DATA_DIR/opm-data/norne/NORNE_ATW2013.DATA \
  --threads-per-process=1 --output-dir=output
