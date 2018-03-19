#!/usr/bin/env bash
set -e

[ -n "${PULL}" ] && git pull --rebase

git fetch
if [ -z "${BRANCH}" ];
 then
 echo "Using default branch";
else
 git fetch
 echo "Checking out branch '${BRANCH}' for $(pwd)";
 git checkout ${BRANCH};
fi

echo "cloned into $(REPO_DIR)"
