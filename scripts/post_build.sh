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

printf "\n${MAGENTA}Post-build steps...${RESET}\n\n"

printf " ->${CYAN} Adding go.mod file to sdk/go/pulumicomponentsdemo...${RESET}\n"
cp go.mod sdk/go/pulumicomponentsdemo/

printf " ->${CYAN} Replace module path in sdk/go/pulumicomponentsdemo/go.mod...${RESET}\n"
( cd sdk/go/pulumicomponentsdemo/ && go mod edit -module github.com/neovasili/pulumi-components-demo/sdk/go/pulumicomponentsdemo )

printf " ->${CYAN} Applying mod tidy to sdk/go/pulumicomponentsdemo...${RESET}\n"
( cd sdk/go/pulumicomponentsdemo/ && go mod tidy )

printf " ->${CYAN} Copy package.json to provider built directory...${RESET}\n"
cp package.json dist/plugin/

printf "\n${GREEN}✅ Post-build steps completed successfully!${RESET}\n"
