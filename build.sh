#!/usr/bin/env bash
set -e

[ -n "${PULL}" ] && git pull --rebase

GIT_PROJECT=$(basename $(pwd))
echo "BUILDING PROJECT $GIT_PROJECT from $(pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

PROJECTS=${PROJECTS:-activiti}

FIRST_REPO=

if [ -n "${CHECK_VERSIONS}" ];
then
  INNER_COUNTER=0
  echo "CHECKING VERSIONS DURING BUILD"


    while read REPO_LINE_INNER;
     do REPO_ARRAY_INNER=($REPO_LINE_INNER)
       REPO_INNER=${REPO_ARRAY_INNER[0]}
       PROP_INNER=${REPO_ARRAY_INNER[0]}
       VERSION_INNER=${REPO_ARRAY_INNER[1]}

       if [ -z "${VERSION_INNER}" ];
       then
         break
       fi

       POM_VERSION=$(mvn help:evaluate -B -Dexpression=project.version | grep -e '^[^\[]' 2>/dev/null) || true
       POM_VERSION=${POM_VERSION#"null object or invalid expression"}

       if [ "${RELEASE_VERSION}" == "${POM_VERSION}" ];
       then
         REPO_ARRAY_INNER[1]=${RELEASE_VERSION}
         VERSION_INNER=${RELEASE_VERSION}
       fi

       if [ "${REPO_INNER}" = "${GIT_PROJECT}" ];
         then
           echo "CHECKING THAT ${GIT_PROJECT} VERSION IS ${REPO_ARRAY_INNER[1]}"
           if [ "${POM_VERSION}" != "${REPO_ARRAY_INNER[1]}" ]
             then
               echo "EXPECTED POM VERSION ${REPO_ARRAY_INNER[1]} BUT IS ${POM_VERSION}"
               exit 1
             else
               echo "${GIT_PROJECT} VERSION IS ${REPO_ARRAY_INNER[1]} AS EXPECTED"
               break
           fi
       else
           echo "CHECKING THAT ${GIT_PROJECT} USES ${PROP_INNER}.version ${REPO_ARRAY_INNER[1]}"

           PARENT_VERSION=$(mvn help:evaluate -B -Dexpression=project.parent.version | grep -e '^[^\[]' 2>/dev/null) || true
           PARENT_VERSION=${PARENT_VERSION#"null object or invalid expression"}

           if [ "${INNER_COUNTER}" -eq "0" ];
           then
             if [ "${PARENT_VERSION}" = "${REPO_ARRAY_INNER[1]}" ];
               then
                 echo "${REPO_INNER} ${VERSION_INNER} IS USED IN PARENT OF ${GIT_PROJECT}"
               else
                 echo "${REPO_INNER} ${VERSION_INNER} IS NOT USED IN PARENT OF ${GIT_PROJECT}"
                 exit 1
             fi
           fi

           PROPERTY_VERSION=$(mvn help:evaluate -B -Dexpression=${PROP_INNER}.version | grep -e '^[^\[]' 2>/dev/null) || true
           PROPERTY_VERSION=${PROPERTY_VERSION#"null object or invalid expression"}

           if [ -z "${PROPERTY_VERSION}" ];
             then
               echo "PROPERTY ${PROP_INNER} IS NOT USED IN ${GIT_PROJECT}"
             else
               if [ "${PROPERTY_VERSION}" = "${REPO_ARRAY_INNER[1]}" ]
                 then
                   echo "${REPO_INNER} ${VERSION_INNER} IS USED IN ${PROP_INNER}.version PROPERTY OF ${GIT_PROJECT}"
               else
                 echo "${GIT_PROJECT} USES ${PROPERTY_VERSION} FOR ${PROP_INNER}.version WHEN EXPECTED VERSION IS ${VERSION_INNER}"
                 exit 1
               fi
           fi

       fi
       INNER_COUNTER=$((INNER_COUNTER+1))
     done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
fi

if [ -e "pom.xml" ]; then
    mvn ${MAVEN_ARGS:-clean install}
else
    echo "No pom.xml - not building"
fi
