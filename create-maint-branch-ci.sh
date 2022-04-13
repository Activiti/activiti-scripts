#!/usr/bin/env bash
set -e

readonly BASE_TAG=$(yq -e '.release.baseTag' release.yaml)
./fetch-versions.sh "$BASE_TAG"

git add "*.txt"

./clone-all.sh

BRANCH=$(yq -e '.release.branch' release.yaml) \
VERSION=$(yq -e '.release.nextVersion' release.yaml) \
./create-maint-branch-all.sh
