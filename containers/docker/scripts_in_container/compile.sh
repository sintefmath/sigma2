#!/bin/bash
set -e

bash ${SCRIPT_DIR}/compile_dune.sh ${@:2}
bash ${SCRIPT_DIR}/compile_opm.sh ${@:2}
