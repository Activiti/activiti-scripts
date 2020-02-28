#!/usr/bin/env bash
set -e
VERSION_TO_RELEASE=v$(<VERSION)
echo "Version to release ${VERSION_TO_RELEASE}"

git remote rm origin
git remote add origin https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/activiti-scripts.git

git tag -fa "${VERSION_TO_RELEASE}" -m "Release version ${VERSION_TO_RELEASE}"
git push origin "${VERSION_TO_RELEASE}"
