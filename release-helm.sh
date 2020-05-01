#!/usr/bin/env bash
set -ex

output=$(echo "$VERSION" | grep -q "MOCK")
if [ -z != "$output" ] ; then export HELM_ACTIVITI_VERSION=$(cat VERSION|rev|sed 's/\./-/'|sed 's/\./-/'|rev) ; fi
echo HELM_ACTIVITI_VERSION=${HELM_ACTIVITI_VERSION}

git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-application.git
cp VERSION  activiti-cloud-application/activiti-cloud-dependencies/

cd activiti-cloud-application/activiti-cloud-dependencies
mvn -q versions:set -Droot.log.level=off -DnewVersion=${VERSION}
make updatebot/push-version-dry

cat .updatebot-repos/github/activiti/activiti-cloud-full-chart/charts/activiti-cloud-full-example/requirements.yaml

sleep 20
cd ..
make update-version-in-example-charts
make create-helm-charts-release-and-upload

cd activiti-cloud-dependencies

make prepare-helm-chart
make run-helm-chart
sleep 120
cd ../..

cd activiti-cloud-application/activiti-cloud-acceptance-scenarios
mvn -DskipITs -DskipTests -q clean install -f activiti-cloud-acceptance-scenarios/pom.xml
mvn -pl 'modeling-acceptance-tests' -Droot.log.level=off -q clean verify
mvn -pl 'runtime-acceptance-tests'  -Droot.log.level=off -q clean verify
cd -

cd activiti-cloud-application/activiti-cloud-dependencies
make replace-release-full-chart-names
make tag
make github
cd -

