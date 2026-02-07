#!/usr/bin/env bash
set -euo pipefail

# Normal colors
BLACK='\e[0;30m'
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
MAGENTA='\e[0;35m'
CYAN='\e[0;36m'
WHITE='\e[0;37m'
GREY='\e[0;90m'

# Bright colors
LIGHT_BLACK='\e[1;30m'
LIGHT_RED='\e[1;31m'
LIGHT_GREEN='\e[1;32m'
LIGHT_YELLOW='\e[1;33m'
LIGHT_BLUE='\e[1;34m'
LIGHT_MAGENTA='\e[1;35m'
LIGHT_CYAN='\e[1;36m'
LIGHT_WHITE='\e[1;37m'
LIGHT_GREY='\e[1;90m'

RESET='\e[0m'

export BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY
export LIGHT_BLACK LIGHT_RED LIGHT_GREEN LIGHT_YELLOW LIGHT_BLUE LIGHT_MAGENTA LIGHT_CYAN LIGHT_WHITE LIGHT_GREY
export RESET

show_script_info() {
  local script_path=$1
  local arguments=("${@:2}")

  printf "\n${LIGHT_CYAN}Running script: ${RESET}'%s'\n" "${script_path}"
  if [ ${#arguments[@]} -gt 0 ]; then
    printf "${LIGHT_CYAN}With arguments:${RESET}\n"
    for arg in "${arguments[@]}"; do
      if [[ "${arg}" == -* ]]; then
        printf "  %s " "${arg}"
      else
        printf "%s\n" "${arg}"
      fi
    done
  fi
  printf "\n"
}
