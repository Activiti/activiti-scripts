#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"
export SCRIPT_DIR

SCRIPT="${SCRIPT_DIR}/create-maint-branch.sh" "${SCRIPT_DIR}"/run.sh
