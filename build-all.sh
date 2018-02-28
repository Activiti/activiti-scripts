#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/build.sh" ${SCRIPT_DIR}/for-each-repo.sh
