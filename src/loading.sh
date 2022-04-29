evaluate_script() {
  script="${1}"

  if [[ ! -f "${script}" ]]; then
    fail "Can't locate filet script {{magenta}}${script}{{/}} ({{magenta}}${script:A}{{/}})"
  fi
  
  if [[ ! -v FILET_SCRIPT_ENVIRONMENT_LOADED ]]; then
    source "${FILET_SRC}"/script-environment.sh 
    FILET_SCRIPT_ENVIRONMENT_LOADED=yes
    FILET_ROOT_SCRIPT="${script:A}"
    FILET_ROOT_DIR="${script:A:h}"
    FILET_STATE_DIR="${FILET_ROOT_DIR}/.filet"
    FILET_REPOSITORIES=()
  fi

  previous_module_root="${FILET_CURRENT_MODULE_ROOT}"
  FILET_CURRENT_MODULE_ROOT="${script:A:h}"

  source "${script}"

  FILET_CURRENT_MODULE_ROOT="${previous_module_root}"
}
