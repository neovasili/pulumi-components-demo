#!/usr/bin/env bash
set -euo pipefail

source scripts/common.sh

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")
show_script_info "${script_path}" "$@"

PLUGIN_NAME=$(jq -e -r '.name' package.json)
VERSION=$(jq -e -r '.version' package.json)

# Comma-separated list override, e.g. PULUMI_PLUGIN_PLATFORMS="darwin-arm64,linux-amd64"
PLATFORMS_RAW="${PULUMI_PLUGIN_PLATFORMS:-darwin-arm64,linux-amd64}"
IFS=',' read -r -a PLATFORMS <<< "${PLATFORMS_RAW}"

OUT_DIR="release-artifacts"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

printf "\n${MAGENTA}Building plugin tarballs...${RESET}\n"
printf "  name:    %s\n  version: %s\n  out:     %s\n  targets: %s\n\n" \
  "${PLUGIN_NAME}" "${VERSION}" "${OUT_DIR}" "${PLATFORMS_RAW}"

for os_arch in "${PLATFORMS[@]}"; do
  printf " ->${CYAN} Packaging for %s...${RESET}\n" "${os_arch}"

  STAGE_DIR="$(mktemp -d "/tmp/pulumi-plugin-stage-${PLUGIN_NAME}-${os_arch}-XXXXXX")"

  cp -f package.json "${STAGE_DIR}/"
  cp -f PulumiPlugin.yaml "${STAGE_DIR}/"
  cp -f tsconfig.json "${STAGE_DIR}/"
  cp -f index.ts "${STAGE_DIR}/"
  cp -R components "${STAGE_DIR}/components"
  cp -R plugin "${STAGE_DIR}/plugin"
  cp -R dist "${STAGE_DIR}/dist"
  cp -R bin "${STAGE_DIR}/bin"

  # Remove workspace node_modules to avoid symlinks from pnpm
  find "${STAGE_DIR}/components" -type d -name node_modules -prune -exec rm -rf '{}' +

  # Install deps with pnpm. Use hoisted linker + ignore scripts to avoid postinstall
  # and then dereference symlinks when creating the tarball.
  (cd "${STAGE_DIR}" && pnpm install --prod --ignore-scripts --node-linker=hoisted)

  TARBALL="${OUT_DIR}/pulumi-resource-${PLUGIN_NAME}-v${VERSION}-${os_arch}.tar.gz"
  tar -C "${STAGE_DIR}" -h --hard-dereference \
    --exclude='./node_modules/.pnpm' \
    --exclude='./node_modules/.pnpm/**' \
    -czf "${TARBALL}" .

  rm -rf "${STAGE_DIR}"
done

printf "\n${GREEN}✅ Plugin tarballs ready in %s${RESET}\n" "${OUT_DIR}"
