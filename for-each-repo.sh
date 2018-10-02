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

    INNER_COUNTER=0

    while read REPO_LINE_INNER;
     do REPO_ARRAY_INNER=($REPO_LINE_INNER)
       REPO_INNER=${REPO_ARRAY_INNER[0]}
       PROP_INNER=${REPO_ARRAY_INNER[1]}
       VERSION_INNER=${REPO_ARRAY_INNER[2]}

       POM_VERSION=$(xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" "${SRC_DIR:-$HOME/src}/$REPO/pom.xml") || true

       if [ "${COUNTER}" -eq "${INNER_COUNTER}" ];
         then
           echo "CHECKING THAT ${REPO} VERSION IS ${REPO_ARRAY_INNER[2]}"
           if [ "${POM_VERSION}" != "${REPO_ARRAY_INNER[2]}" ]
             then
               "POM VERSION DOES NOT MATCH"
               exit 1
           fi
       fi

       if [ "${COUNTER}" -gt "${INNER_COUNTER}" ];
         then
           echo "CHECKING THAT ${REPO} USES ${PROP_INNER} ${REPO_ARRAY_INNER[2]}"

           PARENT_VERSION=$(xmllint --xpath "//*[local-name()='parent']/*[local-name()='version']/text()" "${SRC_DIR:-$HOME/src}/$REPO/pom.xml" 2>/dev/null) || true
           VERSION_USED=false

           if [ "${PARENT_VERSION}" = "${REPO_ARRAY_INNER[2]}" ]
             then
               echo "${REPO_INNER} ${VERSION_INNER} IS USED IN PARENT OF ${REPO}"
               VERSION_USED=true
             else
               echo "${REPO_INNER} ${VERSION_INNER} IS NOT USED IN PARENT OF ${REPO}"
           fi

           PROPERTY_VERSION=$(xmllint --xpath "//*[local-name()='properties']/*[local-name()='${PROP_INNER}']/text()" "${SRC_DIR:-$HOME/src}/$REPO/pom.xml" 2>/dev/null) || true
           if [ -z "${PROPERTY_VERSION}" ];
             then
               echo "PROPERTY ${PROP_INNER} IS NOT USED IN ${REPO}"
             else
               if [ "${PROPERTY_VERSION}" = "${REPO_ARRAY_INNER[2]}" ]
                 then
                   echo "${REPO_INNER} ${VERSION_INNER} IS USED IN ${PROP_INNER} PROPERTY OF ${REPO}"
                   VERSION_USED=true
               else
                 echo "${REPO} USES ${PROPERTY_VERSION} FOR ${PROP_INNER} WHEN EXPECTED VERSION IS ${VERSION_INNER}"
                 exit 1
               fi
           fi

           if [ "$VERSION_USED" = "false" ]
           then
             echo "WARNING - ${REPO_INNER} ${VERSION_INNER} IS NOT USED DIRECTLY IN ${REPO}"
           fi
       fi
       INNER_COUNTER=$((INNER_COUNTER+1))
     done < "$SCRIPT_DIR/repos-${PROJECT}.txt"

    COUNTER=$((COUNTER+1))
  done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
done
