#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS=${PROJECTS:-activiti}

echo "SCRIPT_DIR ${SRC_DIR:-$HOME/src}"
mkdir -p ${SRC_DIR:-$HOME/src} && cd $_

REPO_ARRAYS[0]=''
COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    REPO_ARRAYS[${COUNTER}]="${REPO_ARRAY[0]} ${REPO_ARRAY[1]} ${REPO_ARRAY[2]}"
    echo "REPO_ARRAYS[${COUNTER}] ${REPO_ARRAYS[${COUNTER}]}"
    REPO=${REPO_ARRAY[0]}
    echo "REPO_LINE ${REPO_ARRAY}"
    echo "REPO ${REPO}"
    TAG=${REPO_ARRAY[2]}
    echo "TAG ${TAG}"

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

    if [ $((COUNTER))>0 ];
     then
     for REPO_ARRAY_INNER in ${REPO_ARRAYS}
      do
        echo "REPO_ARRAY_INNER ${REPO_ARRAY_INNER}"
      done
    fi

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done

for REPO_ARRAY in ${REPO_ARRAYS}
do
  echo "REPO_ARRAY ${REPO_ARRAY}"
done
