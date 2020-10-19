#!/bin/bash
set -e
## Author: Franz G. Fuchs

module purge
source modules_to_load.sh

location=`pwd`

parallel_build_tasks=9

#############################################
### Zoltan
#############################################



export INSTALL_PREFIX=$location"/boost"

#bash install_boost.sh
#bash build_scotch.sh
bash install_trilinos.sh
rm -rf trilinostest
#############################################
### Dune
#############################################

cd $location
alias mpic++='mpicxx'
export MPICXX=mpicxx
for repo in dune-common dune-geometry dune-grid dune-istl
do
    echo "=== Cloning and building module: $repo"
    if [[ ! -d $repo ]]; then
        git clone -b releases/2.6 https://gitlab.dune-project.org/core/$repo.git
    fi
    (
        cd $repo
        git pull
	mkdir -p build
	cd build
	
	#FIXME: The prefix path pointing to SuiteSparse seems to be needed
	#but it is rather ugly
	cmake ..  -DBUILD_TESTING=OFF -DCMAKE_PREFIX_PATH="${location}/openblas;/cluster/software/SuiteSparse/5.4.0-intel-2018b-METIS-5.1.0/" -DMPI_CXX_COMPILER=mpicxx -DMPI_C_COMPILER=mpicc -DCMAKE_BUILD_TYPE=Release
        make -j $parallel_build_tasks
    )
done

#############################################
### opm
#############################################

cd $location

for repo in opm-common opm-material opm-grid opm-models opm-simulators
do
    if [[ ! -d $repo ]]; then
        git clone https://github.com/OPM/$repo.git
    fi
    (
        cd $repo
        git pull
	mkdir -p build
        cd build
	#FIXME: The prefix path pointing to SuiteSparse seems to be needed
	#but it is rather ugly
        cmake .. -DBUILD_TESTING=OFF -DUSE_MPI=1  -DCMAKE_PREFIX_PATH="/cluster/software/SuiteSparse/5.4.0-intel-2018b-METIS-5.1.0/;${location}/openblas;${location}/scotch/;${location}/trilinostestinstall;${location}/dune-common/build/;${location}/dune-geometry/build/;${location}/dune-grid/build/;${location}/dune-istl/build/;${location}/boost" -DCMAKE_BUILD_TYPE=Release -Wno-dev -DMPI_CXX_COMPILER=mpicxx -DMPI_C_COMPILER=mpicc -DCMAKE_BUILD_TYPE=Release
        make -j $parallel_build_tasks
	if [[ $repo ==  'opm-common' ]];
	then
	    rm -rf bin/*;
	fi

    )
done


