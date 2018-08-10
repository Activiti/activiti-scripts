#!/usr/bin/env bash

echo update pom version from ${VERSION} to ${NEXT_VERSION}

SED_REPLACEMENTS="${SED_REPLACEMENTS}-e 's@>${VERSION}<@>${NEXT_VERSION}<@g'"

if [[ "$OSTYPE" == "darwin"* ]]
then
  eval "find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  find . -name pom.xml.bak -delete
else
  eval "find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
fi
