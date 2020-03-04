#!/usr/bin/env bash
set -e
VERSION_TO_RELEASE=v$(<VERSION)
echo "Version to release ${VERSION_TO_RELEASE}"

git remote rm origin
git remote add origin https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/activiti-scripts.git

./fetch-versions.sh Activiti "${ACTIVITI_CORE_VERSION}"
./fetch-versions.sh activiti-cloud "${ACTIVITI_CLOUD_DEPENDENCIES_VERSION}"

git add *.txt
git commit -m "Update versions - Activiti Core: ${ACTIVITI_CORE_VERSION} - Activiti Cloud Dependencies: ${ACTIVITI_CLOUD_DEPENDENCIES_VERSION}"

git tag -f -a "${VERSION_TO_RELEASE}" -m "Release version ${VERSION_TO_RELEASE}"
git push origin "${VERSION_TO_RELEASE}"
