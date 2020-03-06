#!/usr/bin/env bash
set -e

./clone-all.sh

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

./release-all.sh #switch to the right tag
./dockerpush-all.sh

