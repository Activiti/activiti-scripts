#!/usr/bin/env bash
set -e

[ -n "${PULL}" ] && git pull --rebase

mvn ${MAVEN_ARGS:-clean install}
