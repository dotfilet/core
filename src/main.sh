#!/usr/bin/env zsh

FILET_SRC="${FILET_HOME:-${0:A:h:h}}"/src
source "${FILET_SRC}"/logging.sh
source "${FILET_SRC}"/commands/apply.sh
source "${FILET_SRC}"/commands/help.sh

# Entry Point

main() (
  log

  local positional=()
  local flags=()

  for argument in "${@}"; do
    if [[ "${argument}" =~ ^-+ ]]; then
      flags+=("${argument}")
    else
      positional+=("${argument}")
    fi
  done

  if (( $flags[(Ie)--help] )) || (( $flags[(Ie)-h] )) || ! is_function "command_${positional[1]}_main"; then
    if [[ "${positional[1]}" != "help" ]]; then
      positional=(help "${positional[@]}")
    fi
  fi
  
  (
    set -e
    "command_${positional[1]}_main" "${positional[@]:1}" "${flags[@]}"
  )
  local result=$?

  log

  return $result
)

is_function() (
  typeset -f "${1}" > /dev/null
)

main "$@"
