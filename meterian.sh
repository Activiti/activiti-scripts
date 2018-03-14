#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SCRIPT="java -jar ${HOME}/Downloads/meterian-cli.jar --project-branch=${BRANCH:-develop}"

SCRIPT=${SCRIPT} ${SCRIPT_DIR}/run.sh
