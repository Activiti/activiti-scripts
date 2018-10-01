#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS=${PROJECTS:-activiti}

echo "SCRIPT_DIR ${SRC_DIR:-$HOME/src}"
mkdir -p ${SRC_DIR:-$HOME/src} && cd $_

COUNTER=0
INNER_COUNTER=0

for PROJECT in ${PROJECTS//,/ }
do
  while read REPO_LINE;
    do REPO_ARRAY=($REPO_LINE)
    REPO=${REPO_ARRAY[0]}
    echo "REPO_LINE ${REPO_LINE}"
    echo "REPO ${REPO}"
    TAG=${REPO_ARRAY[2]}
    echo "TAG v${TAG}"

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

    while read REPO_LINE_INNER;
     do REPO_ARRAY_INNER=($REPO_LINE_INNER)
       REPO_INNER=${REPO_ARRAY_INNER[0]}
       PROP_INNER=${REPO_ARRAY_INNER[1]}
       VERSION_INNER=${REPO_ARRAY_INNER[2]}
       if [ "${COUNTER}" -eq "${INNER_COUNTER}" ];
         then
           echo "CHECKING THAT ${REPO} VERSION IS ${REPO_ARRAY_INNER[2]}"
       else
         echo "CHECKING THAT ${REPO} USES ${PROP_INNER} ${REPO_ARRAY_INNER[2]}"
       fi
       INNER_COUNTER=$((INNER_COUNTER+1))
     done < "$SCRIPT_DIR/repos-${PROJECT}.txt"

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done
