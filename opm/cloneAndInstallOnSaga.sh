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

bash install_boost.sh
bash build_scotch.sh
bash install_trilinos.sh

#############################################
### Dune
#############################################

cd $location

for repo in dune-common dune-geometry dune-grid dune-istl
do
    echo "=== Cloning and building module: $repo"
    if [[ ! -d $repo ]]; then
        git clone -b releases/2.6 https://gitlab.dune-project.org/core/$repo.git
    fi
    (
        cd $repo
        git pull
	rm -rf build
        if [[ ! -d build ]]; then
            mkdir build
        fi
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release ..
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
        if [[ ! -d build ]]; then
            mkdir build
        fi
        cd build
        cmake -DUSE_MPI=1  -DCMAKE_PREFIX_PATH="$location/scotch/;$location/trilinostestinstall;$location/dune-common/build/;$location/dune-geometry/build/;$location/dune-grid/build/;$location/dune-istl/build/;$location/boost" -DCMAKE_BUILD_TYPE=Release -Wno-dev .. 
        make -j $parallel_build_tasks
    )
done


