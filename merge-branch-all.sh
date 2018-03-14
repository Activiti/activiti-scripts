#!/usr/bin/env bash
set -e

[ -z "${BRANCH}" ] && exit

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/merge-branch.sh" ${SCRIPT_DIR}/run.sh
