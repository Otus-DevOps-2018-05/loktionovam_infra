#!/usr/bin/env bash

GENERIC_FUNCTIONS=$(pwd)/config-scripts/generic-functions

if [ ! -r "${GENERIC_FUNCTIONS}" ]; then
  logger --tag ${SCRIPT_NAME} --stderr --id=$$ -p user.err "Can't find ${GENERIC_FUNCTIONS} file. Abort."
  exit 2
fi

source "${GENERIC_FUNCTIONS}"

# Due to bug https://github.com/wata727/tflint/issues/167
# disable module from hashicorp modules registry
for DIR in terraform/{,stage,prod};do
    docker_tflint "${DIR}" "--ignore-module=SweetOps/storage-bucket/google"
done
