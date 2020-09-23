#!/usr/bin/env bash
set -e

. "$(dirname "$0")/shared-lib.sh"

mvnInstall() {
  mvn clean install -DskipTests -B
}

GIT_PROJECT=$(basename $(pwd))
echo "Preparing release for project $GIT_PROJECT from $(pwd)"
echo "RELEASE_VERSION: $RELEASE_VERSION"
echo "SCRIPT_DIR IS $SCRIPT_DIR"

RELEASE_BRANCH=release-${RELEASE_VERSION}

git fetch --tags
if  git tag --list | egrep -q "^$RELEASE_VERSION$"
then
  echo "Found tag $RELEASE_VERSION - released already, skipping..."
else
  RELEASE_BRANCH_HEAD=$(git ls-remote --heads origin "${RELEASE_BRANCH}")
  if [[ -n ${RELEASE_BRANCH_HEAD} ]]; then
    echo "Branch ${RELEASE_BRANCH} already exists. Skipping..."
  else
    echo SNAPSHOT_VERSION=${SNAPSHOT_VERSION}
    echo RELEASE_VERSION=${RELEASE_VERSION}

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

    BASEBRANCH=${BASEBRANCH:-develop}

    BASEBRANCHEXISTS=$(git ls-remote origin ${BASEBRANCH}) || true

    if [ -n "$BASEBRANCHEXISTS" ];
      then
        echo 'using' $BASEBRANCH 'as base branch'
      else
        BASEBRANCH=develop
    fi

    if [ -z "${TAG}" ];
    then
      echo "Creating release branch from origin/${BASEBRANCH}..."
      git checkout origin/${BASEBRANCH} -b "${RELEASE_BRANCH}"
    else
      echo "Creating release branch from tags/v${TAG}..."
      git checkout tags/v${TAG} -b "${RELEASE_BRANCH}"
    fi

    initializeS3Variables
    downloadFromS3


    VERSION=${SNAPSHOT_VERSION} NEXT_VERSION=${RELEASE_VERSION} . ${SCRIPT_DIR}/update-pom-version.sh
    checkNoSnapshots

    if [ -n "${GIT_PUSH}" ]
    then
      git add .
      if [ -e "pom.xml" ];
        then
          git commit -m "updating to release version ${RELEASE_VERSION}"
        else
          git commit -m "updating to release version ${RELEASE_VERSION}" || true
      fi
    fi

    if [ -e "pom.xml" ];
    then
      mvnInstall
      echo "Uploading cache to S3: aws s3 sync ${M2_REPOSITORY_DIR} ${S3_M2_REPOSITORY_RELEASE_DIR} ${S3_CLIENT_OPTS}"
      time aws s3 sync "${M2_REPOSITORY_DIR}" "${S3_M2_REPOSITORY_RELEASE_DIR}" "${S3_CLIENT_OPTS}"
    else
      echo "No pom.xml - not building"
    fi

    if [ -n "${GIT_PUSH}" ]
    then
      if [ -e "pom.xml" ];
      then
        git push origin ${RELEASE_BRANCH}
      else
        git push origin ${RELEASE_BRANCH} || true
      fi
    fi

  fi
fi
