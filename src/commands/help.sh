command_main() (
  command="${1}"

  if [[ "${command}" == "" ]]; then
    default_help
  elif [[ ! -f $(command_file "${command}") ]]; then
    log_error "Unknown command: ${COLOR_YELLOW}${command}${COLOR_RESET}"
    log
    default_help
  else
    source $(command_file "${command}")
    command_help
  fi

  exit 1
)

default_help() (
  log "Usage: ${COLOR_CYAN}filet ${COLOR_YELLOW}command${COLOR_RESET}"
)
