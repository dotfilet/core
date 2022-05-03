# Logging

autoload -U colors
colors

color_format() (
  local string="${@}"
  local stack=(default)
  
  while [[ "${string}" =~ '{{([^}]+)}}' ]]; do
    echo -n "${string:0:($MBEGIN - 1)}"

    color="${match[1]}"
    if [[ "${color}" == "/" ]]; then
      current="${stack[-1]}"
      shift -p stack
      if [[ "${current}" == "dim" ]]; then
        echo -n "[22m"
      else
        color="${stack[-1]}"
      fi
    else
      stack+=("${color}")
    fi

    if [[ "${color}" == "dim" ]]; then
      echo -n "[2m"
    else
      echo -n "${fg[$color]}"
    fi

    string="${string:$MEND}"
  done
  echo -n "${string}"
)

log() (
  echo $(color_format "$@[0m") >&2
)

log_debug() (
  log "{{dim}}$@"
)

log_warn() (
  log "{{yellow}}@" 
)

log_error() (
  log "{{red}}$@" 
)

fail() (
  log_error "$@"
  return 1
)
