#!/usr/bin/env bash
set -ex
export MY_WORK_DIR=`pwd`
git clone -b develop https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-application.git
ls -la
cp VERSION  activiti-cloud-application/activiti-cloud-dependencies/

cd activiti-cloud-application/activiti-cloud-dependencies
ls -la 
make updatebot/push-version-dry

cat .updatebot-repos/github/activiti/activiti-cloud-full-chart/charts/activiti-cloud-full-example/requirements.yaml

cd ..
#creating new common chart version and update dependencies in charts
git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-common-chart.git
cd activiti-cloud-common-chart/charts/common
make version
make tag
make release
make github
cd - #return to activiti-cloud-application folder
make update-common-helm-chart-version
# end work with common
make create-helm-charts-release-and-upload

cd activiti-cloud-dependencies
sleep 20
make prepare-helm-chart
make run-helm-chart
sleep 300
cd ../..


cd activiti-cloud-application/activiti-cloud-acceptance-scenarios
mvn -DskipITs -DskipTests -q clean install
mvn -pl 'modeling-acceptance-tests' -Droot.log.level=off -q clean verify
mvn -pl 'runtime-acceptance-tests'  -Droot.log.level=off -q clean verify
cd -

cd activiti-cloud-application/activiti-cloud-dependencies
#make replace-release-full-chart-names
#make prepare-helm-chart
cd ${MY_WORK_DIR}/activiti-cloud-application/activiti-cloud-dependencies/.updatebot-repos/github/activiti/activiti-cloud-full-chart/charts/activiti-cloud-full-example
make version
make tag
make release
make github

cd -

