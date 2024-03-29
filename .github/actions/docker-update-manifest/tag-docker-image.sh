#!/usr/bin/env bash

set -e

# PARAMETERS #################################
BASE_TAG=${1:-$BASE_TAG}
RELEASE_TAG=${2:-$RELEASE_TAG}
DOCKERHUB_ORG=${3:-$DOCKERHUB_ORG}
DOCKER_IMAGE=${4:-$DOCKER_IMAGE}
DOCKERHUB_USERNAME=${5:-$DOCKERHUB_USERNAME}
DOCKERHUB_ACCESS_TOKEN=${6:-$DOCKERHUB_ACCESS_TOKEN}

# DOCKER VARS ################################
AUTH_DOMAIN="auth.docker.io"
AUTH_SERVICE="registry.docker.io"
AUTH_SCOPE="repository:${DOCKERHUB_ORG}/${DOCKER_IMAGE}:pull,push"
AUTH_OFFLINE_TOKEN="1"
AUTH_CLIENT_ID="shell"
API_DOMAIN="registry-1.docker.io"

# Fetching the TOKEN #########################
echo "Fetching TOKEN for $DOCKER_IMAGE"
CONTENT_TYPE="application/vnd.docker.distribution.manifest.v2+json"
TOKEN_URL="https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=${AUTH_SCOPE}&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}"
echo "curl -s -X GET -u ${DOCKERHUB_USERNAME}:${DOCKERHUB_ACCESS_TOKEN} $TOKEN_URL"
TOKEN=$(curl -s -X GET -u "${DOCKERHUB_USERNAME}:${DOCKERHUB_ACCESS_TOKEN}" $TOKEN_URL | jq -r '.token') && \

if [ "$TOKEN" == "null" ]; then
  echo
  echo "ERROR: could not get an authorized token to add a tag to the base tag $BASE_TAG"
  echo "Please, check the credentials used to access DockerHub"
  exit 1
fi

# TODO check what to do in case the version to tag already exists
# TODO we could exit without error and continue or exit with an error and stop the execution.

# Fetching the IMAGE MANIFEST ################
echo "Downloading MANIFEST for $DOCKER_IMAGE"
MANIFESTS_URL="https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/manifests/${BASE_TAG}"
MANIFEST=$(curl -s -H "Accept: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" "${MANIFESTS_URL}") && \
  echo "Manifest downloaded: $MANIFEST"

echo "Tagging $DOCKER_IMAGE with $RELEASE_TAG"
curl -s -X PUT -H "Content-Type: ${CONTENT_TYPE}" \
         -H "Authorization: Bearer ${TOKEN}" \
         -d "${MANIFEST}" \
         "https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/manifests/${RELEASE_TAG}"

VERSIONS=$(curl -s -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/tags/list)

FETCHED_NEW_TAG=$(echo $VERSIONS | jq -r --arg RELEASE_TAG "$RELEASE_TAG" '.tags[]|select(. == $RELEASE_TAG)')

if [ -n "$FETCHED_NEW_TAG" ]; then
  echo
  echo "Base tag '$BASE_TAG' has been tagged with '$RELEASE_TAG'"
else
  echo
  echo "ERROR: the tag '$RELEASE_TAG' has not been created"
  exit 1
fi
