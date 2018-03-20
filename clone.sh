#!/usr/bin/env bash
set -e

[ -n "${PULL}" ] && git pull --rebase

echo "cloned into $(REPO_DIR)"
