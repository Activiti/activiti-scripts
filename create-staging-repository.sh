#!/usr/bin/env bash
set -e

if [ -n "${MAVEN_PUSH}" ]; then
  curl -d @staging-repository-template.xml -u "${SONATYPE_USERNAME}":"${SONATYPE_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    https://oss.sonatype.org/service/local/staging/profiles/"${SONATYPE_PROFILE_ID}"/start >staging-profile.xml
   STAGING_REPOSITORY=$(< staging-profile.xml grep stagedRepositoryId | grep -o "orgactiviti-[0-9]*")
   echo "Created stating repository ${STAGING_REPOSITORY}"
   export STAGING_REPOSITORY
fi
