#!/usr/bin/env bash
set -e

git remote rm origin
git remote add origin https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/activiti-scripts.git

if [ "${TRAVIS_EVENT_TYPE}" = "cron" ]
then
  SHOULD_INCREMENT_VERSION=true
  export SHOULD_INCREMENT_VERSION
fi

./fetch-versions.sh

VERSION_TO_RELEASE=$(<VERSION)
echo "Version to release ${VERSION_TO_RELEASE}"

git add -A
git commit -m "Update versions - Activiti Cloud Dependencies"

if [ -n "${MAVEN_PUSH}" ]; then
  curl -d @staging-repository-template.xml -u "${NEXUS_USERNAME}":"${NEXUS_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    "${NEXUS_URL}"/service/local/staging/profiles/"${NEXUS_PROFILE_ID}"/start \
    grep stagedRepositoryId | grep -o "${NEXUS_STAGING_PROFILE_PATTERN}" > "${NEXUS_STAGING_FILE}"

    echo "Stating repository $(< "${NEXUS_STAGING_FILE}")"

    sed "s/STAGING_ID/$(<"$NEXUS_STAGING_FILE")/g" < settings.xml > settings-tmp.xml && mv settings-tmp.xml settings.xml

    git add "${NEXUS_STAGING_FILE}"
    git add settings.xml
    git commit -m "Set staging repository"
fi


git tag -f -a "${VERSION_TO_RELEASE}" -m "Release version ${VERSION_TO_RELEASE}"
git push origin "${VERSION_TO_RELEASE}"
