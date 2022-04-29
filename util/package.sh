#!/usr/bin/env zsh

FILET_HOME="${FILET_HOME:-${0:A:h:h}}"
FILET_SRC="${FILET_HOME}"/src
FILET_BIN="${FILET_HOME}"/bin

process_file() (
  filename="${1}"

  IFS=""
  while read -r line; do
    if [[ "${line}" =~ ^FILET_SRC= ]]; then 
      # skip
    elif [[ "${line}" =~ '^source (.*FILET_SRC.*)' ]]; then
      process_file $(eval echo "${match[1]}")
    else
      echo "${line}"
    fi
  done < "${filename}"
)

process_file "${FILET_SRC}"/main.sh > "${FILET_BIN}"/filet
chmod +x "${FILET_BIN}"/filet
