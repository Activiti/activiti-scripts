#!/usr/bin/env bash
set -e

git remote rm origin
git remote add origin https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/activiti-scripts.git

if [ "${TRAVIS_EVENT_TYPE}" = "cron" ]
then
  SHOULD_INCREMENT_VERSION=true
  export SHOULD_INCREMENT_VERSION
fi

VERSION_TO_RELEASE=$(<VERSION)
echo "Version to release ${VERSION_TO_RELEASE}"

tag_pattern="${VERSION_TO_RELEASE%-mock*}-alpha*" ./fetch-versions.sh

git add repos-*.txt
git commit -m "Update versions - Activiti Cloud Dependencies"

if [ -n "${MAVEN_PUSH}" ]; then
  STAGING_REPOSITORY_TEMPLATE_FILE=maven-config/staging-repository-template.xml
  sed "s/VERSION_TO_RELEASE/${VERSION_TO_RELEASE}/g" < ${STAGING_REPOSITORY_TEMPLATE_FILE} > \
    staging-repository-template-tmp.xml && \
    mv staging-repository-template-tmp.xml ${STAGING_REPOSITORY_TEMPLATE_FILE}

  curl -d @${STAGING_REPOSITORY_TEMPLATE_FILE} -u "${NEXUS_USERNAME}":"${NEXUS_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    "${NEXUS_URL}"/service/local/staging/profiles/"${NEXUS_PROFILE_ID}"/start \
    grep stagedRepositoryId | grep -o "${NEXUS_STAGING_PROFILE_PATTERN}" > "${NEXUS_STAGING_FILE}"

  echo "Stating repository $(< "${NEXUS_STAGING_FILE}")"

  sed "s/STAGING_ID/$(<"$NEXUS_STAGING_FILE")/g" < "${SETTINGS_XML_FILE_PATH}" > settings-tmp.xml && mv settings-tmp.xml "${SETTINGS_XML_FILE_PATH}"

  git add "${STAGING_REPOSITORY_TEMPLATE_FILE}"
  git add "${NEXUS_STAGING_FILE}"
  git add "${SETTINGS_XML_FILE_PATH}"
  git commit -m "Set staging repository"
fi


git tag -f -a "${VERSION_TO_RELEASE}" -m "Release version ${VERSION_TO_RELEASE}"
git push origin "${VERSION_TO_RELEASE}"
