#!/usr/bin/env bash
set -e

if [ -n "${MAVEN_PUSH}" ]; then
  echo "Writing create repository response to ${SONATYPE_STAGING_FILE}"
  curl -d @staging-repository-template.xml -u "${SONATYPE_USERNAME}":"${SONATYPE_PASSWORD}" \
    -H "Content-Type:application/xml" -v \
    https://oss.sonatype.org/service/local/staging/profiles/"${SONATYPE_PROFILE_ID}"/start > "${SONATYPE_STAGING_FILE}"
    ll
    echo "Sonatype directory content: "
    ls ${SONATYPE_HOME}
    ./extract-staging-repository.sh
fi
