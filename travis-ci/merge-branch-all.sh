#!/usr/bin/env bash
set -e

[ -z "${BRANCH}" ] && exit

export SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/merge-branch.sh" . ${SCRIPT_DIR}/run.sh
