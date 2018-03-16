#!/usr/bin/env bash
set -e


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS=${PROJECTS:-activiti}

for PROJECT in ${PROJECTS//,/ }
do
  REPOS="${REPOS} $(cat $SCRIPT_DIR/repos-${PROJECT}.txt)"
done

cd ${SRC_DIR:-$HOME/src}
for REPO in ${REPOS}
do
  rm -rf ${REPO}
done
