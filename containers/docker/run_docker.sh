#!/bin/bash
set -e

PROGRAM_DIR=$(pwd)/scratch
SCRATCH_SCRIPT_DIR=$(pwd)/scripts
INSTALL_PREFIX_SCRATCH_BASE=${PROGRAM_DIR}/install

DENYLIST_DIR=$(pwd)/clang_denylist

if [ ! -d $PROGRAM_DIR ];
then
  mkdir -p $PROGRAM_DIR
fi

docker run -it --rm \
  -v $SCRATCH_SCRIPT_DIR:$SCRATCH_SCRIPT_DIR \
  -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
  -v $DENYLIST_DIR:$DENYLIST_DIR \
  --env DENYLIST_DIR=${DENYLIST_DIR} \
  --env INSTALL_PREFIX_SCRATCH_BASE=${INSTALL_PREFIX_SCRATCH_BASE} \
  --user $(id -u):$(id -g) \
  --env CMAKE_BUILD_TYPE=RelWithDebInfo \
  --env CC=clang \
  --env CXX=clang++ \
  kjetilly/opm_mpi "COMPILE" $1

docker run -it --rm \
    -v $SCRATCH_SCRIPT_DIR:$SCRATCH_SCRIPT_DIR \
    -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
    -v $DENYLIST_DIR:$DENYLIST_DIR \
    --env DENYLIST_DIR=${DENYLIST_DIR} \
    --env INSTALL_PREFIX_SCRATCH_BASE=${INSTALL_PREFIX_SCRATCH_BASE} \
    --env SOURCE_CODE_DIR="$PROGRAM_DIR" \
    --env CC=clang \
    --env CXX=clang++ \
    --user  $(id -u):$(id -g) \
    kjetilly/opm_mpi "RUN" $1 $2


#     --env ASAN_OPTIONS=halt_on_error=0 \
