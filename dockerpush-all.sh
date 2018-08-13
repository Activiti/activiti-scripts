#!/usr/bin/env bash
set -ex

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

echo "SCRIPT_DIR contains"

for entry in "$SCRIPT_DIR"/*
do
  echo "$entry"
done

echo "ls -ltr returns"

ls -ltr

SCRIPT="${SCRIPT_DIR}/dockerpush.sh" ${SCRIPT_DIR}/run.sh
