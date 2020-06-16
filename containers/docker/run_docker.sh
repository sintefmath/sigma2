#!/bin/bash
set -e

PROGRAM_DIR=$(pwd)/scratch

if [ ! -d $PROGRAM_DIR ];
then
  mkdir -p $PROGRAM_DIR
fi

docker run -it --rm -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
  --user $(id -u):$(id -g) \
  --env CMAKE_BUILD_TYPE=RelWithDebInfo \
  --env CC=clang \
  --env CXX=clang++ \
  opm_mpi "COMPILE" $1

docker run -it --rm -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
    --env SOURCE_CODE_DIR="$PROGRAM_DIR" \
    --env CC=clang \
    --env CXX=clang++ \
    --env ASAN_OPTIONS=halt_on_error=0 \
    --user  $(id -u):$(id -g) \
    opm_mpi "RUN" $1 $2
