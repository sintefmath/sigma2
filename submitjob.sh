#!/bin/bash

#SBATCH --account=NN9766K
#SBATCH --job-name=norne
#SBATCH --time=0-01:00:00
#SBATCH --mem-per-cpu=3G
#SBATCH --ntasks=1 --cpus-per-task=1 --ntasks-per-node=1

## Recommended safety settings:
set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

module --quiet purge
module load CMake/3.12.1
module load Boost/1.71.0-GCC-8.3.0
module load GCC/8.3.0
module load OpenMPI/3.1.4-GCC-8.3.0
module load OpenBLAS/0.3.7-GCC-8.3.0
module list

cp ~/opm/opm-data/norne/NORNE_ATW2013.DATA $SCRATCH
cp -r ~/opm/opm-data/norne/INCLUDE/ $SCRATCH
cd $SCRATCH

savefile output/*

time mpirun ~/opm/opm-simulators/build/bin/flow NORNE_ATW2013.DATA --output-dir=output

exit 0
