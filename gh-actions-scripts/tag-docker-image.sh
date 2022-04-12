#!/usr/bin/env bash

set -e

# PARAMETERS #################################
BASE_TAG=${1:-BASE_TAG}
RELEASE_TAG=${2:-RELEASE_TAG}

DOCKER_HUB_ORG=${3:-DOCKER_HUB_ORG}
DOCKER_HUB_REPO=${4:-DOCKER_HUB_REPO}
DOCKER_HUB_USER=${5:-DOCKER_HUB_USER}
DOCKER_HUB_PASSWORD=${6:-DOCKER_HUB_PASSWORD}

# DOCKER VARS ################################
AUTH_DOMAIN="auth.docker.io"
AUTH_SERVICE="registry.docker.io"
AUTH_SCOPE="repository:${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}:pull,push"
AUTH_OFFLINE_TOKEN="1"
AUTH_CLIENT_ID="shell"
API_DOMAIN="registry-1.docker.io"

# Fetching the TOKEN #########################
CONTENT_TYPE="application/vnd.docker.distribution.manifest.v2+json"
TOKEN_URL="https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=${AUTH_SCOPE}&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}"
TOKEN=$(curl -X GET -u ${DOCKER_HUB_USER}:${DOCKER_HUB_PASSWORD} $TOKEN_URL | jq -r '.token') && echo $TOKEN

# Fetching the IMAGE MANIFEST ################
MANIFESTS_URL="https://${API_DOMAIN}/v2/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/manifests/${BASE_TAG}"
MANIFEST=$(curl -H "Accept: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" "${MANIFESTS_URL}") && echo $MANIFEST

curl -X PUT -H "Content-Type: ${CONTENT_TYPE}" \
         -H "Authorization: Bearer ${TOKEN}" \
         -d "${MANIFEST}" \
         "https://${API_DOMAIN}/v2/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/manifests/${RELEASE_TAG}"

VERSIONS=$(curl -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/tags/list)

echo $VERSIONS
