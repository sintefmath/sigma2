#!/bin/bash
set -e

PROGRAM_DIR=$(pwd)/scratch

if [ ! -d $PROGRAM_DIR ];
then
  mkdir -p $PROGRAM_DIR
fi

docker run -it --rm -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
  --user $(id -u):$(id -g) opm_mpi "COMPILE" $2

docker run -it --rm -v $PROGRAM_DIR:$PROGRAM_DIR -w $PROGRAM_DIR \
    --env SOURCE_CODE_DIR="$PROGRAM_DIR" --user  $(id -u):$(id -g)   opm_mpi "RUN" $3
