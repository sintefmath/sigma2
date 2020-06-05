#!/bin/bash
set -e

if [[ $# -eq 0 ]];
then
  number_of_processes=1
else
  number_of_processes=$1
fi

# Make sure MPI believes we have enough slots
echo "localhost slots=$number_of_processes" > hostfile

# Run simulator
time mpirun --hostfile hostfile -np $number_of_processes $SOURCE_CODE_DIR/opm-simulators/build/bin/flow \
  $DATA_DIR/opm-data/norne/NORNE_ATW2013.DATA \
  --threads-per-process=1 --output-dir=output
