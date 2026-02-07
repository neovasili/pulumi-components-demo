#!/usr/bin/env bash
set -euo pipefail

source scripts/common.sh

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")
show_script_info "${script_path}" "$@"

debug_mode=false
while getopts "d" opt; do
  case "${opt}" in
    d) debug_mode=true ;;
  esac
done

PLUGIN_NAME=$(jq -e -r '.name' package.json)
VERSION=$(jq -e -r '.version' package.json)

# We keep your explicit platform target
OS_ARCH="darwin-arm64"

# stage directory in repo (safe to delete/recreate)
STAGE_DIR=".pulumi-plugin-stage"

# tarball Pulumi will install from
TARBALL="/tmp/pulumi-resource-${PLUGIN_NAME}-v${VERSION}-${OS_ARCH}.tar.gz"

printf "\n${MAGENTA}Installing local plugin via pulumi plugin install:${RESET}\n"
printf "  name:    %s\n  version: %s\n  tarball: %s\n\n" "${PLUGIN_NAME}" "${VERSION}" "${TARBALL}"

printf " ->${CYAN} Cleaning previous stage...${RESET}\n"
rm -rf "${STAGE_DIR}"
mkdir -p "${STAGE_DIR}"

printf " ->${CYAN} Removing any previously installed plugin (best-effort)...${RESET}\n"
# Don't fail if it doesn't exist
pulumi plugin rm resource "${PLUGIN_NAME}" --yes >/dev/null 2>&1 || true

# --- ensure build + deps exist ---
if [ ! -d node_modules ]; then
  printf "${RED}ERROR: node_modules missing. Run 'pnpm install' first.${RESET}\n" >&2
  exit 1
fi

if [ ! -d dist ]; then
  printf "${RED}ERROR: dist missing. Run 'pnpm build' first.${RESET}\n" >&2
  exit 1
fi

printf " ->${CYAN} Copying plugin files...${RESET}\n"
cp -f package.json "${STAGE_DIR}/"
cp -f pnpm-lock.yaml "${STAGE_DIR}/"
cp -f PulumiPlugin.yaml "${STAGE_DIR}/"
cp -R dist "${STAGE_DIR}/dist"
cp -R bin "${STAGE_DIR}/bin"

printf " ->${CYAN} Creating plugin executable...${RESET}\n"
PLUGIN_EXE="${STAGE_DIR}/pulumi-resource-${PLUGIN_NAME}"

cat > "${PLUGIN_EXE}" <<'EON'
#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "${PLUGIN_DIR}/node_modules" ]; then
  (cd "${PLUGIN_DIR}" && pnpm install --prod --frozen-lockfile)
fi

# Run the provider server entrypoint (compiled JS).
# IMPORTANT: do not write anything to stdout from here.
exec node "${PLUGIN_DIR}/dist/plugin/provider.js"
EON

chmod +x "${PLUGIN_EXE}"

printf " ->${CYAN} Installing plugin dependencies in stage (prod only)...${RESET}\n"
( cd "${STAGE_DIR}" && pnpm install --prod --frozen-lockfile )

printf " ->${CYAN} Creating plugin tarball...${RESET}\n"
rm -f "${TARBALL}"
tar -C "${STAGE_DIR}" -czf "${TARBALL}" .

printf " ->${CYAN} Installing plugin from tarball into Pulumi...${RESET}\n"
pulumi plugin install resource --non-interactive "${PLUGIN_NAME}" "${VERSION}" --file "${TARBALL}"

printf " ->${CYAN} Verifying installation...${RESET}\n"
pulumi plugin ls | grep -E "${PLUGIN_NAME}\s+resource\s+${VERSION}" || {
  printf "${RED}ERROR: Plugin not found in 'pulumi plugin ls' output after install.${RESET}\n" >&2
  exit 1
}

printf "\n${GREEN}✅ Local plugin installation completed successfully!${RESET}\n"
printf "Tarball: %s\n" "${TARBALL}"
