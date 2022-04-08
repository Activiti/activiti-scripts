#!/usr/bin/env bash
set -e

git checkout -b "$BRANCH"

yq e -i '.github.organisations[].repositories[].branch = env(BRANCH)' .updatebot.yml

yq e -i '.on.push.branches = [ env(BRANCH) ]' .github/workflows/main.yml
yq e -i '.on.pull_request.branches = [ env(BRANCH) ]' .github/workflows/main.yml

NEXT_VERSION=${VERSION%\-SNAPSHOT}
yq -i e '(.jobs.build.steps[] |  select(.id == "next-release") | .with.next-version) |=  env(NEXT_VERSION) ' .github/workflows/main.yml

mvn -B versions:set -DnewVersion="$VERSION" -DprocessAllModules=true -DgenerateBackupPoms=false

git add -u
git status
git --no-pager diff --cached
git commit -m "Configure branch $BRANCH"
git push origin "$BRANCH"
