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

  # Ensure the plugin executable is at the root (Pulumi expects this).
  if [ -f "${STAGE_DIR}/bin/pulumi-resource-${PLUGIN_NAME}" ]; then
    cp -f "${STAGE_DIR}/bin/pulumi-resource-${PLUGIN_NAME}" "${STAGE_DIR}/pulumi-resource-${PLUGIN_NAME}"
    chmod +x "${STAGE_DIR}/pulumi-resource-${PLUGIN_NAME}"
  fi

  # Remove workspace node_modules to avoid symlinks from pnpm
  find "${STAGE_DIR}/components" -type d -name node_modules -prune -exec rm -rf '{}' +

  # Install deps with npm to avoid pnpm symlinks/hardlinks in node_modules.
  # Skip scripts to avoid running postinstall during packaging.
  # Disable bin-links so npm doesn't create symlinks in node_modules/.bin.
  (cd "${STAGE_DIR}" && npm_config_bin_links=false npm install --omit=dev --no-package-lock --ignore-scripts)

  # Drop any .bin directories (they can contain symlinks and aren't needed at runtime).
  find "${STAGE_DIR}/node_modules" -type d -name .bin -prune -exec rm -rf '{}' +

  TARBALL="${OUT_DIR}/pulumi-resource-${PLUGIN_NAME}-v${VERSION}-${os_arch}.tar.gz"
  TAR_FLAGS=(-czf "${TARBALL}" -h)
  if tar --help 2>&1 | grep -q -- '--hard-dereference'; then
    TAR_FLAGS+=(--hard-dereference)
  fi
  tar -C "${STAGE_DIR}" "${TAR_FLAGS[@]}" .

  rm -rf "${STAGE_DIR}"
done

printf "\n${GREEN}✅ Plugin tarballs ready in %s${RESET}\n" "${OUT_DIR}"
