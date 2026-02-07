#!/usr/bin/env bash

set -euo pipefail

source scripts/common.sh

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")

show_script_info "${script_path}" "$@"

language=
debug_mode=false
while getopts "l:d" opt; do
  case "${opt}" in
    l)
      language="${OPTARG}"
      ;;
    d)
      debug_mode=true
      ;;
  esac
done

if [ -z "${language}" ]; then
  printf "\n${RED}Error: Language not specified. Use -l to specify the target language (e.g., nodejs, go).${RESET}\n\n"
  exit 1
fi

printf "\n${MAGENTA}Generating SDK for language: ${RESET}'%s'\n" "${language}"

printf " ->${CYAN} Cleaning previous SDK artifacts...${RESET}\n"
rm -rf "sdk/${language}/"

printf " ->${CYAN} Generating SDK...${RESET}\n"
if [ "${debug_mode}" = true ]; then
  if ! pulumi package gen-sdk schema/schema.json --out "sdk/" --language "${language}" -v=3; then
    printf "\n${RED}Error: SDK generation failed for language: ${RESET}'%s'\n" "${language}"
    exit 1
  fi
else
  if ! pulumi package gen-sdk schema/schema.json --out "sdk/" --language "${language}" > /dev/null 2>&1; then
    printf "\n${RED}Error: SDK generation failed for language: ${RESET}'%s'\n" "${language}"
    exit 1
  fi
fi

printf "\n${GREEN}✅ SDK generated successfully for language: ${RESET}'%s'\n" "${language}"
