#!/usr/bin/env bash
set -e

git pull --rebase

mvn ${MAVEN_ARGS:-clean install}
