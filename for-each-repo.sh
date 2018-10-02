#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS=${PROJECTS:-activiti}

echo "SCRIPT_DIR ${SRC_DIR:-$HOME/src}"
mkdir -p ${SRC_DIR:-$HOME/src} && cd $_

COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    REPO=${REPO_ARRAY[0]}
    echo "REPO_LINE ${REPO_LINE}"
    echo "REPO ${REPO}"
    TAG=${REPO_ARRAY[1]}
    echo "TAG v${TAG}"

    pushd ${PWD} > /dev/null
    echo "*************** EXECUTE ON ${REPO} :: START ***************"
    if ! [ -d "${REPO}" ]
    then
      REPO_DIR=$(dirname ${REPO})
      mkdir -p ${REPO_DIR}
      cd ${REPO_DIR}
      git clone git@github.com:Activiti/${REPO}.git
      cd $(basename ${REPO})
    else
      cd ${REPO}
    fi
    if [ -z "${TAG}" ];
     then
     echo "Using default branch";
    else
     git fetch
     echo "Checking out tag '${TAG}' for $(pwd)";
     git checkout tags/v$TAG || ${IGNORE_TAG_CHECKOUT_FAILURE:true}
    fi
    ${SCRIPT:-echo I\'m in ${REPO}}
    echo "*************** EXECUTE ON ${REPO} :: END   ***************"
    popd > /dev/null

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done
