#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version 2>/dev/null | grep -v "^\[")

NEXT_RELEASE_VERSION=`echo ${CURRENT_VERSION} | cut -c1-11`
YEAR=`echo ${CURRENT_VERSION} | cut -c3-6`
MONTH=`echo ${CURRENT_VERSION} | cut -c7-8`
DATE=${YEAR}-${MONTH}-1

if [[ "$OSTYPE" == "darwin"* ]]
then
  NEXT_DATE=$(date -v+1m -jf "%Y-%m" "+%Y-%m" ${DATE})
else
  NEXT_DATE=$(date +%Y%m -d "$DATE + 1 month")
fi

NEXT_SNAPSHOT_VERSION=7-${NEXT_DATE}-EA-SNAPSHOT

echo NEXT_RELEASE_VERSION=${NEXT_RELEASE_VERSION}
echo NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}

find . -name pom.xml -exec sed -i.bak -e "s/${CURRENT_VERSION}/${NEXT_RELEASE_VERSION}/g" {} \;
