#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS=${PROJECTS:-activiti}

for PROJECT in ${PROJECTS//,/ }
do
  REPOS="${REPOS} $(cat $SCRIPT_DIR/repos-${PROJECT}.txt)"
done

echo SCRIPT_DIR=${SCRIPT_DIR}
echo REPOS=${REPOS}
echo SCRIPT=${SCRIPT}

mkdir -p ${SRC_DIR:-$HOME/src} && cd $_
for REPO in ${REPOS}
do
  pushd ${PWD} > /dev/null
  echo "*************** EXECUTE ON ${REPO} :: START ***************"
  if ! [ -d "${REPO}" ]
  then
    REPO_DIR=$(dirname ${REPO})
    mkdir -p ${REPO_DIR}
    cd ${REPO_DIR}
    git clone git@github.com:${REPO}.git
    cd $(basename ${REPO})
  else
    cd ${REPO}
  fi
  if [ -z "${BRANCH}" ];
   then
   echo "Using default branch";
  else
   git fetch
   echo "Checking out branch '${BRANCH}' for $(pwd)";
   git checkout $BRANCH || ${IGNORE_BRANCH_CHECKOUT_FAILURE:true}
  fi
  ${SCRIPT:-echo I\'m in ${REPO}}
  echo "*************** EXECUTE ON ${REPO} :: END   ***************"
  popd > /dev/null
done
