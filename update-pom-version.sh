#!/usr/bin/env bash

echo update pom version from ${VERSION} to ${NEXT_VERSION}

if [[ "$OSTYPE" == "darwin"* ]]
then
  find . -name pom.xml -exec sed -i.bak -e "s/<version>${VERSION}<\/version>/<version>${NEXT_VERSION}<\/version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti.version>${VERSION}/<\/activiti.version><activiti.version>${NEXT_VERSION}<\/activiti.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-service-common.version>${VERSION}<\/activiti-cloud-service-common.version>/<activiti-cloud-service-common.version>${NEXT_VERSION}<\/activiti-cloud-service-common.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-runtime-bundle.version>${VERSION}<\/activiti-cloud-runtime-bundle.version>/<activiti-cloud-runtime-bundle.version>${NEXT_VERSION}<\/activiti-cloud-runtime-bundle.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-audit.version>${VERSION}<\/activiti-cloud-audit.version>/<activiti-cloud-audit.version>${NEXT_VERSION}<\/activiti-cloud-audit.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-query.version>${VERSION}<\/activiti-cloud-query.version>/<activiti-cloud-query.version>${NEXT_VERSION}<\/activiti-cloud-query.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-connectors.version>${VERSION}<\/activiti-cloud-connectors.version>/<activiti-cloud-connectors.version>${NEXT_VERSION}<\/activiti-cloud-connectors.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-process-model.version>${VERSION}<\/activiti-cloud-process-model.version>/<activiti-cloud-process-model.version>${NEXT_VERSION}<\/activiti-cloud-process-model.version>/g" {} \;
  find . -name pom.xml -exec sed -i.bak -e "s/<activiti-cloud-org.version>${VERSION}<\/activiti-cloud-org.version>/<activiti-cloud-org.version>${NEXT_VERSION}<\/activiti-cloud-org.version>/g" {} \;
  find . -name pom.xml.bak -delete
else
  find . -name pom.xml -exec sed -i -e "s/<version>${VERSION}<\/version>/<version>${NEXT_VERSION}<\/version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti.version>${VERSION}/<\/activiti.version><activiti.version>${NEXT_VERSION}<\/activiti.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-service-common.version>${VERSION}<\/activiti-cloud-service-common.version>/<activiti-cloud-service-common.version>${NEXT_VERSION}<\/activiti-cloud-service-common.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-runtime-bundle.version>${VERSION}<\/activiti-cloud-runtime-bundle.version>/<activiti-cloud-runtime-bundle.version>${NEXT_VERSION}<\/activiti-cloud-runtime-bundle.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-audit.version>${VERSION}<\/activiti-cloud-audit.version>/<activiti-cloud-audit.version>${NEXT_VERSION}<\/activiti-cloud-audit.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-query.version>${VERSION}<\/activiti-cloud-query.version>/<activiti-cloud-query.version>${NEXT_VERSION}<\/activiti-cloud-query.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-connectors.version>${VERSION}<\/activiti-cloud-connectors.version>/<activiti-cloud-connectors.version>${NEXT_VERSION}<\/activiti-cloud-connectors.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-process-model.version>${VERSION}<\/activiti-cloud-process-model.version>/<activiti-cloud-process-model.version>${NEXT_VERSION}<\/activiti-cloud-process-model.version>/g" {} \;
  find . -name pom.xml -exec sed -i -e "s/<activiti-cloud-org.version>${VERSION}<\/activiti-cloud-org.version>/<activiti-cloud-org.version>${NEXT_VERSION}<\/activiti-cloud-org.version>/g" {} \;
fi
