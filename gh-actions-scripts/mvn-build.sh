#!/usr/bin/env bash
set -e

PATH=${1:-.}

pushd $PATH

if [ ! -e "pom.xml" ]; then
    echo "no pom.xml file - this is not a maven project"
    exit 1
fi

mvn ${MAVEN_ARGS:-clean install
  -DskipTests \
  -Dhttp.keepAlive=false \
  -Dmaven.wagon.http.pool=false \
  -Dmaven.wagon.httpconnectionManager.ttlSeconds=120}

popd
