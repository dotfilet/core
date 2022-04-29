source "${FILET_SRC}"/loading.sh

command_apply_help() (
  log "Usage: ${COLOR_CYAN}filet ${COLOR_YELLOW}apply ${COLOR_MAGENTA}file.filet${COLOR_RESET}"
)

command_apply_main() (
  root_script="${1}"
  if [[ "${root_script}" == "" ]]; then
    command_apply_help
    return 1
  fi

  cd "${root_script:h}"
  evaluate_script "${root_script}"
)
