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

printf "\n${MAGENTA}Building the project...${RESET}\n\n"

printf " ->${CYAN} Cleaning previous build artifacts...${RESET}\n"
rm -rf dist/

printf " ->${CYAN} Building the project...${RESET}\n"
if [ "${debug_mode}" = true ]; then
  if ! tsc -p tsconfig.json -v; then
    printf "\n${RED}Error: Build failed!${RESET}\n"
    exit 1
  fi
else
  if ! tsc -p tsconfig.json > /dev/null 2>&1; then
    printf "\n${RED}Error: Build failed!${RESET}\n"
    exit 1
  fi
fi

printf "\n${GREEN}✅ Build completed successfully!${RESET}\n"
