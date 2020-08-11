#!/bin/bash
set -e
set -o xtrace
location=`pwd`

parallel_build_tasks=4
export CC=$(which gcc)
export CXX=$(which g++)

#############################################
### Zoltan
#############################################


export INSTALL_PREFIX=$location"/boost"
export CXXFLAGS='-O2'
export CFLAGS='-O2'
export LDFLAGS=''

BOOST_MAJOR_VERSION=1
BOOST_MINOR_VERSION=73
BOOST_RELEASE_VERSION=0
wget -q https://dl.bintray.com/boostorg/release/${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_RELEASE_VERSION}/source/boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2
tar xf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2
cd boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}
##CXX=${MY_CXX} ./bootstrap.sh --with-libraries=all --prefix=$INSTALL_PREFIX #program_options,filesystem,system,regex,thread,chrono,date_time,log,spirit --prefix=$INSTALL_PREFIX
./bootstrap.sh --with-python=$(which python3) --with-libraries=python,program_options,filesystem,system,regex,thread,chrono,date_time,log,test --prefix=$INSTALL_PREFIX || (cat bootstrap.log && exit 1)
./b2 --threading=multi --toolset=gcc --layout=tagged install
cd ..
rm -rf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}
rm -rf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2

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
    -DCMAKE_C_FLAGS='-fPIE' \
    -DCMAKE_CXX_FLAGS='-fPIE' \
    -Wno-dev \
    ../
    make -j $parallel_build_tasks
    make install
    cd $location
    rm -rf Trilinos
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
        cmake -DUSE_MPI=1  -DCMAKE_PREFIX_PATH="$location/zoltan/;$location/dune-common/build/;$location/dune-geometry/build/;$location/dune-grid/build/;$location/dune-istl/build/;$location/boost" -DCMAKE_BUILD_TYPE=Release -Wno-dev ..
        make -j $parallel_build_tasks
    )
done
