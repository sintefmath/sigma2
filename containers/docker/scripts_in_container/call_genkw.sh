#!/bin/bash
export ASAN_OPTIONS=halt_on_error=0
echo "Calling genkw $@"
/opm_pure/opm-common/build/bin/genkw "$@" 2> /dev/null
exit 0
