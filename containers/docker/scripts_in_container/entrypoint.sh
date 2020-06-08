#!/bin/bash

set -e


if [[ $# -eq 0 ]];
then
  program="RUN"
else
  program=$1
fi

if [ $program == "RUN" ];
then
  bash ${SCRIPT_DIR}/run_simulator.sh "${@:2}"
elif [ $program == "COMPILE" ];
then
  bash ${SCRIPT_DIR}/compile.sh "${@:2}"
else
  >&2 echo "Unknown program ${program}"
fi
