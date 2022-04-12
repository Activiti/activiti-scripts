#!/usr/bin/env bash
set -e


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS=${PROJECTS:-activiti}
echo "PROJECTs to remove: " ${PROJECTS}

for PROJECT in ${PROJECTS//,/ }
do
  REPOS="${REPOS} $(cat $SCRIPT_DIR/repos-${PROJECT}.txt)"
done

cd ${SRC_DIR:-$HOME/src}
for REPO in ${REPOS}
do
  rm -rf ${REPO}
  echo "rm -rf ${REPO}"
done
