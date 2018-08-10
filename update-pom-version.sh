#!/usr/bin/env bash

echo update pom version from ${VERSION} to ${NEXT_VERSION}

for DEP in '' activiti activiti-cloud-service-common activiti-cloud-runtime-bundle activiti-cloud-audit activiti-cloud-query activiti-cloud-connectors activiti-cloud-app activiti-cloud-process-model activiti-cloud-org activiti.cloud
do
  [ -n "$DEP" ] && TAG="${DEP}."
  TAG="${TAG}version"
  [ -n "${SED_REPLACEMENTS}" ] && SED_REPLACEMENTS="${SED_REPLACEMENTS} "
  SED_REPLACEMENTS="${SED_REPLACEMENTS}-e 's@<${TAG}>${VERSION}</${TAG}>@<${TAG}>${NEXT_VERSION}</${TAG}>@g'"
done

if [[ "$OSTYPE" == "darwin"* ]]
then
  eval "find . -name pom.xml -exec sed -i.bak ${SED_REPLACEMENTS} {} \;"
  find . -name pom.xml.bak -delete
else
  eval "find . -name pom.xml -exec sed -i ${SED_REPLACEMENTS} {} \;"
fi
