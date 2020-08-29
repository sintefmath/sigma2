#!/bin/bash
set -e
set -o xtrace
location=`pwd`

parallel_build_tasks=4
export CC=$(which gcc)
export CXX=$(which g++)


#export CFLAGS='-O2'
#export CXXFLAGS='-O2'
export CFLAGS="-fPIE -fno-omit-frame-pointer -O0 -g"
export CXXFLAGS="-fPIE -fno-omit-frame-pointer -O0 -g"
export LDFLAGS=""
export INSTALL_PREFIX=$location"/mpi"
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
    ./configure --prefix=$INSTALL_PREFIX --disable-fortran --disable-mpi-fortran
    make install
    cd ${SOURCE_CODE_DIR}
  fi
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
    ./configure --prefix=$INSTALL_PREFIX --disable-fortran
    make install
    cd ${SOURCE_CODE_DIR}
  fi
else
  >&2 echo "Unknown MPI type ${OPM_MPI_TYPE}".
  exti 1
fi

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
    -D DCMAKE_PREFIX_PATH="$location/mpi" \
    -D TPL_ENABLE_MPI:BOOL=ON \
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_Zoltan:BOOL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-fPIE -I$location/mpi/include" \
    -DCMAKE_CXX_FLAGS='-fPIE -I$location/mpi/include' \
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
        cmake -DCMAKE_BUILD_TYPE=Release .. -DCMAKE_PREFIX_PATH="$location/mpi" \
          -DCMAKE_C_FLAGS="-fPIE -I$location/mpi/include" \
          -DCMAKE_CXX_FLAGS='-fPIE -I$location/mpi/include'
        make VERBOSE=1 -j $parallel_build_tasks
    )
done

#############################################
### opm
#############################################

cd $location

for repo in opm-common
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
        cmake -DBUILD_FLOW=OFF \
          -DUSE_MPI=1 \
          -DCMAKE_PREFIX_PATH="$location/mpi;$location/zoltan/;$location/dune-common/build/;$location/dune-geometry/build/;$location/dune-grid/build/;$location/dune-istl/build/;$location/boost" \
          -DCMAKE_BUILD_TYPE=Release -Wno-dev .. \
          -DCMAKE_C_FLAGS="-fPIE -I$location/mpi/include" \
          -DCMAKE_CXX_FLAGS='-fPIE -I$location/mpi/include'
        make -j $parallel_build_tasks
    )
done
