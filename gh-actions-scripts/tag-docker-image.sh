#!/usr/bin/env bash

set -e

# PARAMETERS #################################
BASE_TAG=${1:-BASE_TAG}
RELEASE_TAG=${2:-RELEASE_TAG}
DOCKERHUB_ORG=${3:-DOCKERHUB_ORG}
DOCKER_IMAGE=${4:-DOCKER_IMAGE}
DOCKERHUB_USERNAME=${5:-DOCKERHUB_USERNAME}
DOCKERHUB_PASSWORD=${6:-DOCKERHUB_PASSWORD}

# DOCKER VARS ################################
AUTH_DOMAIN="auth.docker.io"
AUTH_SERVICE="registry.docker.io"
AUTH_SCOPE="repository:${DOCKERHUB_ORG}/${DOCKER_IMAGE}:pull,push"
AUTH_OFFLINE_TOKEN="1"
AUTH_CLIENT_ID="shell"
API_DOMAIN="registry-1.docker.io"

# TODO it should skip if the version is already present

# Fetching the TOKEN #########################
CONTENT_TYPE="application/vnd.docker.distribution.manifest.v2+json"
TOKEN_URL="https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=${AUTH_SCOPE}&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}"
TOKEN=$(curl -X GET -u ${DOCKERHUB_USERNAME}:${DOCKERHUB_PASSWORD} $TOKEN_URL | jq -r '.token') && echo $TOKEN

# Fetching the IMAGE MANIFEST ################
MANIFESTS_URL="https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/manifests/${BASE_TAG}"
MANIFEST=$(curl -H "Accept: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" "${MANIFESTS_URL}") && echo $MANIFEST

curl -X PUT -H "Content-Type: ${CONTENT_TYPE}" \
         -H "Authorization: Bearer ${TOKEN}" \
         -d "${MANIFEST}" \
         "https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/manifests/${RELEASE_TAG}"

VERSIONS=$(curl -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKERHUB_ORG}/${DOCKER_IMAGE}/tags/list)

# TODO it should test if the version is now present
echo $VERSIONS
