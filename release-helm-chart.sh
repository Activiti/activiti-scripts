#!/usr/bin/env bash
set -e
git clone https://$(GITHUB_TOKEN):x-oauth-basic@github.com/Activiti/activiti-cloud-application.git

cd activiti-cloud-application;
mvn -DskipITs -DskipTests -q -f  activiti-cloud-acceptance-scenarios/pom.xml
cd -
cp VERSION  activiti-cloud-dependencies/
cd activiti-cloud-dependencies
mvn -q versions:set -Droot.log.level=off -DnewVersion=$(VERSION)
make updatebot/push-version-dry
sleep 20
make prepare-helm-chart
make run-helm-chart
cd -
sleep 120
cd activiti-cloud-acceptance-scenarios
mvn -pl 'modeling-acceptance-tests' -Droot.log.level=off -q clean verify
mvn -pl 'runtime-acceptance-tests'  -Droot.log.level=off -q clean verify
cd -
cd activiti-cloud-dependencies
make tag
make github
cd -
