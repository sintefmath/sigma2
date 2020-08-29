#!/bin/bash
set -e
echo "#########################################################################"
echo "##########              COMPILING THE UNIVERSE                ###########"
echo "##########                 SIT BACK AND WAIT                  ###########"
echo "##########              THIS COULD TAKE A WHILE               ###########"
echo "#########################################################################"

export SOURCE_CODE_DIR=$(realpath .)
BUILD_POSTFIX="_${CONTAINER_CLANG_SANITIZER}"
export INSTALL_PREFIX_SCRATCH=${INSTALL_PREFIX_SCRATCH_BASE}/${CONTAINER_CLANG_SANITIZER}
mkdir -p ${INSTALL_PREFIX_SCRATCH}
DENYLIST_FILE=${DENYLIST_DIR}/denylist_${CONTAINER_CLANG_SANITIZER}.txt
CLANG_SANITIZE_FLAG="-fsanitize=$1 -fsanitize-blacklist=${DENYLIST_FILE} -fsanitize-recover=${CONTAINER_CLANG_SANITIZER} -fno-omit-frame-pointer -O0 -g -fsanitize-memory-track-origins=2 -fsanitize-memory-use-after-dtor"
export CFLAGS=${CLANG_SANITIZE_FLAG}
export CXXFLAGS=${CLANG_SANITIZE_FLAG}
bash ${SCRATCH_SCRIPT_DIR}/compile_mpi.sh
bash ${SCRATCH_SCRIPT_DIR}/compile_trilinos.sh
bash ${SCRATCH_SCRIPT_DIR}/compile_dune.sh "${@}"
bash ${SCRATCH_SCRIPT_DIR}/compile_opm.sh "${@}"
