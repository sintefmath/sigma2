#!/bin/bash

## Author: Franz G. Fuchs

module purge
module load CMake/3.12.1
module load Boost/1.71.0-GCC-8.3.0
module load GCC/8.3.0
module load OpenMPI/3.1.4-GCC-8.3.0
module load OpenBLAS/0.3.7-GCC-8.3.0

location=`pwd`

parallel_build_tasks=9

#############################################
### Zoltan
#############################################

install_prefix=$location"/zoltan"
if [[ ! -d $install_prefix ]]; then
    mkdir $install_prefix
fi

if [[ ! -d Trilinos ]]; then
    git clone https://github.com/trilinos/Trilinos.git
fi
(
    cd Trilinos
    git checkout trilinos-release-12-8-1
    git pull
    if [[ ! -d build ]]; then
        mkdir build
    fi
    cd build
    cmake \
    -D CMAKE_INSTALL_PREFIX=$install_prefix \
    -D TPL_ENABLE_MPI:BOOL=ON \
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_Zoltan:BOOL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -Wno-dev \
    ../
    make -j $parallel_build_tasks
    make install
    rm -r Trilinos
)

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
        if [[ ! -d $repo ]]; then
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
        cmake -DUSE_MPI=1  -DCMAKE_PREFIX_PATH="$location/zoltan/;$location/dune-common/build/;$location/dune-geometry/build/;$location/dune-grid/build/;$location/dune-istl/build/;" -DCMAKE_BUILD_TYPE=Release -Wno-dev .. 
        make -j $parallel_build_tasks
    )
done


