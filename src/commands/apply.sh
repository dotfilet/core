source "${FILET_SRC}"/loading.sh

# Command: apply

command_apply_help() (
  log "Usage: {{cyan}}filet{{/}} {{yellow}}apply{{/}} {{magenta}}file.filet{{/}}"
)

command_apply_main() (
  local root_script="${1}"
  if [[ "${root_script}" == "" ]]; then
    command_apply_help
    return 1
  fi

  cd "${root_script:h}"
  evaluate_script "${root_script}"
)
