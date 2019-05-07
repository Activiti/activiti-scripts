#!/usr/bin/env bash
set -e

export SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/build.sh" . ${SCRIPT_DIR}/run.sh
