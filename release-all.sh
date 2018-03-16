#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/release-dry-run.sh" ${SCRIPT_DIR}/run.sh
