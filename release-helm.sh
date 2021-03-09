#!/usr/bin/env bash
set -ex

. "$(dirname "$0")/shared-lib.sh"

export MY_WORK_DIR=`pwd`
git clone -b "${VERSION}" https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-application.git
ls -la
cp VERSION  activiti-cloud-application/

initializeS3Variables
downloadFromS3

cd activiti-cloud-application

#creating new common chart version and update dependencies in charts
git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/Activiti/activiti-cloud-common-chart.git
cd activiti-cloud-common-chart/charts/common
make version
make tag
make release
make github
cd - #return to activiti-cloud-application folder

# override FRONT_RELEASE_VERSION otherwise it will use master tag for the docker image
FRONT_RELEASE_VERSION=${VERSION} make install

attempt_counter=0
max_attempts=50
echo "Waiting for services to be up..."
until curl --silent --head --fail \
          ${GATEWAY_HOST}/modeling-service/v2/api-docs > /dev/null 2>&1 &&
      curl --silent --head --fail \
           ${GATEWAY_HOST}/rb/v2/api-docs > /dev/null 2>&1 &&
       curl --silent --head --fail \
            ${GATEWAY_HOST}/query/v2/api-docs > /dev/null 2>&1; do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached"
      break
    fi

    printf '.'
    attempt_counter=$((attempt_counter+1))
    sleep 5
done

kubectl get po -n ${PREVIEW_NAMESPACE}

make test/modeling-acceptance-tests
make test/runtime-acceptance-tests

cd .git/activiti-cloud-full-chart/charts/activiti-cloud-full-example
yq e '{"dependencies": (.dependencies.[] | [select(.name == "common").version = env(VERSION)])}' -i requirements.yaml
yq e '.activiti-modeling-app.image.tag = env(VERSION)' -i values.yaml
make release
make tag
make github

cd -
