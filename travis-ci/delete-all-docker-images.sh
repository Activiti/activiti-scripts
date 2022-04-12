#!/usr/bin/env bash
set -e

function login_data() {
cat <<EOF
{
  "username": "$DOCKER_REGISTRY_USERNAME",
  "password": "$DOCKER_REGISTRY_PASSWORD"
}
EOF
}

function deleteDockerImages() {
  ORGANIZATION="activiti"
  DOCKER_IMAGES="example-runtime-bundle,activiti-cloud-query,example-cloud-connector,activiti-cloud-modeling,activiti-modeling-app"

  for DOCKER_IMAGE in ${DOCKER_IMAGES//,/ }
  do
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token)
    TAG_URL="https://hub.docker.com/v2/repositories/${ORGANIZATION}/${DOCKER_IMAGE}/tags/${RELEASE_VERSION}/"
    echo "Deleting $TAG_URL"
    curl "$TAG_URL" \
    -X DELETE \
    -H "Authorization: JWT ${TOKEN}"
  done
}

RELEASE_VERSION=$(<VERSION)
export RELEASE_VERSION

read -p "Delete tag ${RELEASE_VERSION} from docker registry? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  deleteDockerImages
fi
