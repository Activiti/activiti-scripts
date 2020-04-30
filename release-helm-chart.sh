#!/usr/bin/env bash
set -e

function git_clone() {
  git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-application.git
  cp VERSION  activiti-cloud-application/activiti-cloud-dependencies/
}

function prepare_and_run_helm() {
  cd activiti-cloud-application/activiti-cloud-dependencies
  mvn -q versions:set -Droot.log.level=off -DnewVersion=${VERSION}
  make updatebot/push-version-dry
  sleep 20
  make prepare-helm-chart
  make run-helm-chart
  sleep 120
  cd -
}

function run_acceptance_test() {
  cd activiti-cloud-application/activiti-cloud-acceptance-scenarios
  mvn -DskipITs -DskipTests -q clean install -f activiti-cloud-acceptance-scenarios/pom.xml
  mvn -pl 'modeling-acceptance-tests' -Droot.log.level=off -q clean verify
  mvn -pl 'runtime-acceptance-tests'  -Droot.log.level=off -q clean verify
  cd -
}

function upload_helm_chart() {
  cd activiti-cloud-application/activiti-cloud-dependencies
  make tag
  make github
  cd -
}
