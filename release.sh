#!/usr/bin/env bash
set -e

echo "BAMBOO_OPTS=${BAMBOO_OPTS}"

GIT_PROJECT=$(basename $(pwd))
echo "RELEASING PROJECT $GIT_PROJECT from $(pwd)"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

git remote set-url origin https://${GIT_AUTHOR_NAME}:${GIT_PASSWORD}@github.com/Activiti/${GIT_PROJECT}.git

if  git tag --list | egrep -q "^$RELEASE_VERSION$"
then
  echo "Found tag - released already"
  git checkout $RELEASE_VERSION
    echo "* pushing to origin"
    git checkout ${RELEASE_VERSION}
    echo "DEPLOY_EXISTING: ${DEPLOY_EXISTING}"
    if [ -n "${MAVEN_PUSH}" ]
    then
      echo 'deploying existing repo'
      mvn clean deploy -DperformRelease -DskipTests ${BAMBOO_OPTS}
    else
      mvn clean install -DskipTests
    fi
else
  echo SNAPSHOT_VERSION=${SNAPSHOT_VERSION}
  echo RELEASE_VERSION=${RELEASE_VERSION}
  echo NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}

  echo $GIT_AUTHOR_NAME
  git config user.name "$GIT_AUTHOR_NAME"
  git config user.email "$GIT_AUTHOR_EMAIL"

  for PROJECT in ${PROJECTS//,/ }
  do
    while read REPO_LINE;
      do REPO_ARRAY=($REPO_LINE)
      REPO=${REPO_ARRAY[0]}
      if [ "${REPO}" = "${GIT_PROJECT}" ];
      then
        TAG=${REPO_ARRAY[1]}
      fi
    done < "$SCRIPT_DIR/repos-${PROJECT}.txt"
  done

  if [ -z "${TAG}" ];
  then
    git checkout develop -b release/${RELEASE_VERSION}
  else
    git checkout tags/v${TAG} -b release/${RELEASE_VERSION}
  fi

  VERSION=${SNAPSHOT_VERSION} NEXT_VERSION=${RELEASE_VERSION} . ${SCRIPT_DIR}/update-pom-version.sh

   if [ -n "${GIT_PUSH}" ]
   then
    git add .
    git commit -m "updating to release version ${RELEASE_VERSION}"
    git tag -a ${RELEASE_VERSION} -m "tagging release ${RELEASE_VERSION}"
    git checkout ${RELEASE_VERSION}
   fi


    if [ -e "pom.xml" ];
    then
      if [ -n "${MAVEN_PUSH}" ]
      then
        echo 'deploying existing repo'
        mvn clean deploy -DperformRelease -DskipTests ${BAMBOO_OPTS}
      else
        mvn ${MAVEN_ARGS:-clean install -DskipTests}
      fi
    else
      echo "No pom.xml - not building"
    fi

    if [ -n "${GIT_PUSH}" ]
    then
      git push --atomic origin ${RELEASE_VERSION}
    fi

fi
