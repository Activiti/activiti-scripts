#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

if [ -n "${PROJECTS}" ]
then
  SCRIPT=${SCRIPT} . ${SCRIPT_DIR}/for-each-repo.sh
else
  ${SCRIPT}
fi
