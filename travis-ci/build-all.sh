#!/usr/bin/env bash
set -e

export SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

SCRIPT="${SCRIPT_DIR}/build.sh" ${SCRIPT_DIR}/run.sh
