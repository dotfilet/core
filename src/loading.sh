evaluate_script() {
  script="${1}"

  if [[ ! -f "${script}" ]]; then
    fail "Can't locate filet script ${COLOR_MAGENTA}${script}${COLOR_RED} (${COLOR_MAGENTA}${script:A}${COLOR_RED})"
  fi
  
  if [[ ! -v FILET_SCRIPT_ENVIRONMENT_LOADED ]]; then
    source "${FILET_SRC}"/script-environment.sh 
    FILET_SCRIPT_ENVIRONMENT_LOADED=yes
    FILET_ROOT_SCRIPT="${script:A}"
    FILET_ROOT_DIR="${script:A:h}"
    FILET_STATE_DIR="${FILET_ROOT_DIR}/.filet"
    FILET_REPOSITORIES=()
  fi

  source "${script}"
}
