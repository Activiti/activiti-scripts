#!/usr/bin/env bash
set -ex

export SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SCRIPT="${SCRIPT_DIR}/dockerpush.sh" . ${SCRIPT_DIR}/run.sh
