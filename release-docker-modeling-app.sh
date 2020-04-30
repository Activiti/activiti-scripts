#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

export PROJECTS=activiti-modeling-app
./clone-all.sh

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

SRC_DIR=${SRC_DIR:-$HOME/src}
echo "SCRIPT_DIR ${SRC_DIR}"
cd ${SRC_DIR}/${PROJECTS} || exit 1

git fetch --tags
git checkout "${RELEASE_VERSION}"

./dockerpush-all.sh

