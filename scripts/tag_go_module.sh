#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: scripts/tag_go_module.sh <version> [git-head]" >&2
  exit 2
fi

VERSION="$1"
GIT_HEAD="${2:-}"

TAG="sdk/go/pulumicomponentsdemo/v${VERSION}"

if git show-ref --tags --quiet --verify "refs/tags/${TAG}"; then
  echo "Tag already exists: ${TAG}"
  exit 0
fi

if [ -n "${GIT_HEAD}" ]; then
  git tag "${TAG}" "${GIT_HEAD}"
else
  git tag "${TAG}"
fi

git push origin "refs/tags/${TAG}"
echo "Pushed tag: ${TAG}"
