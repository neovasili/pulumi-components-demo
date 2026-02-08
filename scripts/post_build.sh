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

printf " ->${CYAN} Patching Node SDK package.json (main/types/repository)...${RESET}\n"
tmp_pkg=$(mktemp)
jq '. + {
  name:"@neovasili/pulumi-components-demo",
  main:"bin/index.js",
  types:"bin/index.d.ts",
  repository:{type:"git", url:"https://github.com/neovasili/pulumi-components-demo"},
  homepage:"https://github.com/neovasili/pulumi-components-demo#readme",
  bugs:{url:"https://github.com/neovasili/pulumi-components-demo/issues"}
}' sdk/nodejs/package.json > "${tmp_pkg}"
mv "${tmp_pkg}" sdk/nodejs/package.json

printf " ->${CYAN} Building Node SDK...${RESET}\n"
tsc -p sdk/nodejs/tsconfig.json

printf " ->${CYAN} Copying Node SDK package.json into bin/ (for runtime version lookup)...${RESET}\n"
cp sdk/nodejs/package.json sdk/nodejs/bin/package.json

printf "\n${GREEN}✅ Post-build steps completed successfully!${RESET}\n"
