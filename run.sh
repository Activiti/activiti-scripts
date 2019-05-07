#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

if [ -n "${PROJECTS}" ]
then
  SCRIPT=${SCRIPT} . ${SCRIPT_DIR}/for-each-repo.sh
else
  ${SCRIPT}
fi
