#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

if [ -z "${SNAPSHOT_VERSION}" ]
then
  SNAPSHOT_VERSION=$(mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' -N org.codehaus.mojo:exec-maven-plugin:exec)
fi

if [ -z "${RELEASE_VERSION}" ]
then
  RELEASE_VERSION=`echo ${SNAPSHOT_VERSION} | cut -c1-11`
fi

if [ -z "${NEXT_SNAPSHOT_VERSION}" ]
then
  YEAR=`echo ${SNAPSHOT_VERSION} | cut -c3-6`
  MONTH=`echo ${SNAPSHOT_VERSION} | cut -c7-8`
  DATE=$YEAR-$MONTH-1

  if [[ "$OSTYPE" == "darwin"* ]]
  then
    NEXT_DATE=$(date -v+1m -jf "%Y-%m" "+%Y-%m-" ${DATE})
  else
    NEXT_DATE=$(date +%Y%m -d "$DATE + 1 month")
  fi

  NEXT_SNAPSHOT_VERSION=7-${NEXT_DATE}-EA-SNAPSHOT
fi

echo export SNAPSHOT_VERSION=${SNAPSHOT_VERSION}
echo export RELEASE_VERSION=${RELEASE_VERSION}
echo export NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}
echo '# Run this command to configure your shell:'
echo '# eval $(${SCRIPT_DIR}/new-release-env.sh)'
