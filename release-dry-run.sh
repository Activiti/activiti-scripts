#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

eval $(${SCRIPT_DIR}/new-release-env.sh)

echo CURRENT_VERSION=${CURRENT_VERSION}
echo NEXT_RELEASE_VERSION=${NEXT_RELEASE_VERSION}
echo NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}

if [[ "$OSTYPE" == "darwin"* ]]
then
  find . -name pom.xml -exec sed -i.bak -e "s/${CURRENT_VERSION}/${NEXT_RELEASE_VERSION}/g" {} \;
  find . -name pom.xml.bak -delete
else
  find . -name pom.xml -exec sed -i -e "s/${CURRENT_VERSION}/${NEXT_RELEASE_VERSION}/g" {} \;
fi
