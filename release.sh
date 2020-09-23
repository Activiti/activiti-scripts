#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

mvnDeploy() {
  echo "Deploying to repository ${STAGING_REPOSITORY}"
  mvn clean deploy -DperformRelease -DskipTests -B -DaltReleaseDeploymentRepository=nexus-releases-staging-fixed::default::"${NEXUS_URL}"/service/local/staging/deployByRepositoryId/"${STAGING_REPOSITORY}"
}

GIT_PROJECT=$(basename $(pwd))
echo "RELEASING PROJECT $GIT_PROJECT from $(pwd)"
echo "RELEASE_VERSION: $RELEASE_VERSION"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

RELEASE_BRANCH=release-${RELEASE_VERSION}

initializeS3Variables
downloadFromS3

git fetch --tags
if  git tag --list | egrep -q "^$RELEASE_VERSION$"
then
  echo "Found tag - released already"
  git checkout $RELEASE_VERSION
    echo "* pushing to origin"
    git checkout ${RELEASE_VERSION}
    echo "DEPLOY_EXISTING: ${DEPLOY_EXISTING}"
    if [ -e "pom.xml" ];
    then
      if [ -n "${MAVEN_PUSH}" ] && [ -n "${DEPLOY_EXISTING}" ]
      then
        echo 'deploying existing repo'
        mvnDeploy
      else
        echo 'not deploying ${GIT_PROJECT} to maven - just building'
        mvn ${MAVEN_ARGS:-clean install -DskipTests}
      fi
    else
      echo "No pom.xml - not building"
    fi
else
  echo SNAPSHOT_VERSION=${SNAPSHOT_VERSION}
  echo RELEASE_VERSION=${RELEASE_VERSION}
  echo NEXT_SNAPSHOT_VERSION=${NEXT_SNAPSHOT_VERSION}

  git config user.name "$GIT_AUTHOR_NAME"
  git config user.email "$GIT_AUTHOR_EMAIL"

  git checkout "${RELEASE_BRANCH}"

  if [ -n "${GIT_PUSH}" ]
  then
    git tag -a ${RELEASE_VERSION} -m "tagging release ${RELEASE_VERSION}"
    git checkout ${RELEASE_VERSION}
  fi


  if [ -e "pom.xml" ];
  then
    if [ -n "${MAVEN_PUSH}" ]
    then
      mvnDeploy
    else
      mvn "${MAVEN_ARGS:-clean install -DskipTests}"
    fi
  else
    echo "No pom.xml - not building"
  fi

  if [ -n "${GIT_PUSH}" ]
  then
    if [ -e "pom.xml" ];
    then
      git push --atomic origin "${RELEASE_VERSION}" :"${RELEASE_BRANCH}"
    else
      git push --atomic origin "${RELEASE_VERSION}" :"${RELEASE_BRANCH}"
    fi
  fi

fi
