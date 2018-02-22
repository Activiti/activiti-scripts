#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname $0)

for PROJECT in ${PROJECTS:-activiti}
do
  REPOS="$REPOS $(cat $SCRIPT_DIR/repos-${PROJECT}.txt)"
done

echo SCRIPT_DIR=$SCRIPT_DIR
echo working with REPOS $REPOS

mkdir -p ${SRC_DIR:-~/src} && cd $_
for REPO in $REPOS
do
  pushd $PWD > /dev/null
  echo "*************** BUILDING $REPO START ***************"
  if ! [ -d "$REPO" ]
  then
    REPO_DIR=$(dirname $REPO)
    mkdir -p $REPO_DIR
    cd $REPO_DIR
    git clone git@github.com:$REPO.git
    cd $(basename $REPO)
  else
    cd $REPO
    git fetch
  fi
  if [ -n "$BRANCH" ]
  then
    git checkout ${BRANCH} || git checkout develop
    git pull --rebase
  fi
  mvn ${MAVEN_ARGS:-clean install}
  echo "**************** BUILDING $REPO END ****************"
  popd > /dev/null
done