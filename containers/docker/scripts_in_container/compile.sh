#!/bin/bash
set -e

bash ${SCRIPT_DIR}/compile_dune.sh "${@}"
bash ${SCRIPT_DIR}/compile_opm.sh "${@}"
