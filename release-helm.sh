#!/usr/bin/env bash
set -ex

  git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-application.git
  cp VERSION  activiti-cloud-application/activiti-cloud-dependencies/

  cd activiti-cloud-application/activiti-cloud-dependencies
  mvn -q versions:set -Droot.log.level=off -DnewVersion=${VERSION}
  make updatebot/push-version-dry
  cat activiti-cloud-application/activiti-cloud-dependencies/.updatebot-repos/github/activiti/activiti-cloud-full-chart/charts/activiti-cloud-full-example/values.yaml 
 
  sleep 20
  make prepare-helm-chart
  make run-helm-chart
  sleep 120
  cd -

  cd activiti-cloud-application/activiti-cloud-acceptance-scenarios
  mvn -DskipITs -DskipTests -q clean install -f activiti-cloud-acceptance-scenarios/pom.xml
  mvn -pl 'modeling-acceptance-tests' -Droot.log.level=off -q clean verify
  mvn -pl 'runtime-acceptance-tests'  -Droot.log.level=off -q clean verify
  cd -

  cd activiti-cloud-application/activiti-cloud-dependencies
  make tag
  make github
  cd -

