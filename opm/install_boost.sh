#!/bin/bash
set -e
BOOST_MAJOR_VERSION=1
BOOST_MINOR_VERSION=73
BOOST_RELEASE_VERSION=0
old_dir=$(pwd)

cd  $USERWORK
wget https://dl.bintray.com/boostorg/release/${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_RELEASE_VERSION}/source/boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2
tar xf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2
cd boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}
##CXX=${MY_CXX} ./bootstrap.sh --with-libraries=all --prefix=$INSTALL_PREFIX #program_options,filesystem,system,regex,thread,chrono,date_time,log,spirit --prefix=$INSTALL_PREFIX
CXX=${MY_CXX} ./bootstrap.sh --with-libraries=program_options,filesystem,system,regex,thread,chrono,date_time,log,test --prefix=$INSTALL_PREFIX
./b2 -d0 --link=static threading=multi --toolset=$MY_CC --layout=tagged install
cd ..
rm -rf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}
rm -rf boost_${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_RELEASE_VERSION}.tar.bz2
cd $old_dir
