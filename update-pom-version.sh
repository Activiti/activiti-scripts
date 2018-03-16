#!/usr/bin/env bash

echo update pom version from ${VERSION} to ${NEXT_VERSION}

if [[ "$OSTYPE" == "darwin"* ]]
then
  find . -name pom.xml -exec sed -i.bak -e "s/${VERSION}/${NEXT_VERSION}/g" {} \;
  find . -name pom.xml.bak -delete
else
  find . -name pom.xml -exec sed -i -e "s/${VERSION}/${NEXT_VERSION}/g" {} \;
fi
