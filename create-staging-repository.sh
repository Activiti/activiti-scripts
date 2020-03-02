#!/usr/bin/env bash
set -e

if [ -n "${MAVEN_PUSH}" ]; then
  curl -d @staging-repository-template.xml -u "${SONATYPE_USERNAME}":"${SONATYPE_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    https://oss.sonatype.org/service/local/staging/profiles/"${SONATYPE_PROFILE_ID}"/start \
    grep stagedRepositoryId | grep -o "orgactiviti-[0-9]*" > "${SONATYPE_STAGING_FILE}"

    echo "Stating repository "
    cat "${SONATYPE_STAGING_FILE}"
fi
