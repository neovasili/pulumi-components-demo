#!/usr/bin/env bash

set -euo pipefail

source scripts/common.sh

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")

show_script_info "${script_path}" "$@"

debug_mode=false
while getopts "d" opt; do
  case "${opt}" in
    d)
      debug_mode=true
      ;;
  esac
done

printf "\n${MAGENTA}Generating schema...${RESET}\n\n"

printf " ->${CYAN} Cleaning previous schema artifacts...${RESET}\n"
rm -rf schema/

printf " ->${CYAN} Creating schema directory...${RESET}\n"
mkdir -p schema/

printf " ->${CYAN} Generating Pulumi package schema...${RESET}\n"
if [ "${debug_mode}" = true ]; then
  if ! pulumi package get-schema . > schema/schema.json; then
    printf "\n${RED}Error: Schema generation failed!${RESET}\n"
    exit 1
  fi
else
  if ! pulumi package get-schema . > schema/schema.json; then
    printf "\n${RED}Error: Schema generation failed!${RESET}\n"
    exit 1
  fi
fi

printf " ->${CYAN} Patching schema for Go SDK...${RESET}\n"
tmp_schema="$(mktemp)"
if ! jq '
  .language.go.importBasePath = "github.com/neovasili/pulumi-components-demo/sdk/go/pulumicomponentsdemo"
| .language.go.modulePath     = "github.com/neovasili/pulumi-components-demo/sdk/go/pulumicomponentsdemo"
' schema/schema.json > "${tmp_schema}"; then
  printf "\n${RED}Error: Failed to patch schema for Go SDK!${RESET}\n"
  rm -f "${tmp_schema}"
  exit 1
fi
mv "${tmp_schema}" schema/schema.json

printf "\n${GREEN}✅ Schema generated successfully!${RESET}\n"
