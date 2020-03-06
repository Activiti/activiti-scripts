#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"
export SCRIPT_DIR

SCRIPT="${SCRIPT_DIR}/release.sh" "${SCRIPT_DIR}"/run.sh
