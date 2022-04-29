command_help_main() (
  command="${1}"

  if [[ "${command}" == "" ]]; then
    default_help
  elif ! is_function "command_${command}_main"; then
    log_error "Unknown command: ${COLOR_YELLOW}${command}${COLOR_RESET}"
    log
    default_help
  elif ! is_function "command_${command}_help"; then
    log_error "The ${COLOR_YELLOW}${command}${COLOR_RED} command failed to implement command_${command}_help"
    log
    default_help
  else
    "command_${command}_help"
  fi

  exit 1
)

default_help() (
  log "Usage: ${COLOR_CYAN}filet ${COLOR_YELLOW}command${COLOR_RESET}"
)
