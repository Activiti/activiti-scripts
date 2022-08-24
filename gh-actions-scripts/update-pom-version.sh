#!/usr/bin/env bash

RELEASE_VERSION=${1:-$RELEASE_VERSION}
TAG_VERSION=${2:-$TAG_VERSION}
POM_VERSION=$(mvn help:evaluate -B -Dexpression=project.version | grep -e '^[^\[]' 2>/dev/null) || true
POM_VERSION=${POM_VERSION#"null object or invalid expression"}
POM_VERSION=${3:-$POM_VERSION}

echo "Updating versions in pom.xml files to ${RELEASE_VERSION}"
echo " - TAG_VERSION: $TAG_VERSION"
echo " - POM_VERSION: $POM_VERSION"

SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's|${POM_VERSION}|${RELEASE_VERSION}|g'"
SED_REPLACEMENTS="${SED_REPLACEMENTS} -e 's|${TAG_VERSION}|${RELEASE_VERSION}|g'"

if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  find . -name pom.xml.bak -delete
else
  eval "find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
fi

echo "Checking for occurrences of non final versions..."
grep -r '[0-9]*\.[0-9]*\.[0-9]*\-SNAPSHOT\|[0-9]*\.[0-9]*\.[0-9]*\-alpha\.[0-9]*' --include=pom.xml . \
  && echo "At least one occurrence of a non final version was found. Stopping the release..." && exit 1 \
  || echo "No occurrences of non final versions was found. Proceeding with the release..."
