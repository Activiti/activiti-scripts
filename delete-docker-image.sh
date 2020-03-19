#!/usr/bin/env bash
set -e

GIT_PROJECT=$(basename $(pwd))
ORGANIZATION="activiti"

login_data() {
cat <<EOF
{
  "username": "$DOCKER_REGISTRY_USERNAME",
  "password": "$DOCKER_REGISTRY_PASSWORD"
}
EOF
}

TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token)
TAG_URL="https://hub.docker.com/v2/repositories/${ORGANIZATION}/${GIT_PROJECT}/tags/${RELEASE_VERSION}/"
echo "Deleting $TAG_URL"
curl "$TAG_URL" \
-X DELETE \
-H "Authorization: JWT ${TOKEN}"
