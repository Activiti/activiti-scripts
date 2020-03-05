#!/usr/bin/env bash
set -e
VERSION_TO_RELEASE=v$(<VERSION)
echo "Version to release ${VERSION_TO_RELEASE}"

git remote rm origin
git remote add origin https://"${GITHUB_TOKEN}":x-oauth-basic@github.com/Activiti/activiti-scripts.git

./fetch-versions.sh Activiti "${ACTIVITI_CORE_VERSION}"
./fetch-versions.sh activiti-cloud-dependencies "${ACTIVITI_CLOUD_DEPENDENCIES_VERSION}"

git add *.txt
git commit -m "Update versions - Activiti Core: ${ACTIVITI_CORE_VERSION} - Activiti Cloud Dependencies: ${ACTIVITI_CLOUD_DEPENDENCIES_VERSION}"

if [ -n "${MAVEN_PUSH}" ]; then
  curl -d @staging-repository-template.xml -u "${SONATYPE_USERNAME}":"${SONATYPE_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    https://oss.sonatype.org/service/local/staging/profiles/"${SONATYPE_PROFILE_ID}"/start \
    grep stagedRepositoryId | grep -o "orgactiviti-[0-9]*" > "${SONATYPE_STAGING_FILE}"

    echo "Stating repository $(< "${SONATYPE_STAGING_FILE}")"

    sed "s/STAGING_ID/$(<"$SONATYPE_STAGING_FILE")/g" < settings.xml > settings-tmp.xml && mv settings-tmp.xml settings.xml

    git add "${SONATYPE_STAGING_FILE}"
    git add settings.xml
    git commit -m "Set staging repository"
fi


git tag -f -a "${VERSION_TO_RELEASE}" -m "Release version ${VERSION_TO_RELEASE}"
git push origin "${VERSION_TO_RELEASE}"
