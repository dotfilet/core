# Script Environment

import() {
  repository="${1}"

  if [[ "${repository}" =~ ^github: ]]; then
    import_git "https://github.com/${repository:7}"
  elif [[ -d "${repository}" ]]; then
    import_path "${repository}"
  else
    fail "Not able to resolve repository {{yellow}}${repository}{{/}} to import"
  fi
}

import_git() {
  url="${1}"
  relative_path="${url:8}" # assuming https://…

  cache_dir="${FILET_STATE_DIR}/repositories/${relative_path}"

  if [[ -d "${cache_dir}" ]]; then
    # TODO: Make this an explicit command to sync?
    #
    # git -C "${cache_dir}" pull --depth 1 --rebase --quiet
  else
    log "Caching ${url} to ${cache_dir}…"

    mkdir -p "${cache_dir:h}"
    git clone --depth 1 "${url}" "${cache_dir}"
  fi

  import_path "${cache_dir}"
}

import_path() {
  repository_path="${1:A}"
  log_debug "import ${repository_path}"

  if [[ ! -d "${repository_path}" ]]; then
    fail "Unable to import unknown directory {{magenta}}${repository_path}{{/}} ({{magenta}}${repository_path}{{/}})"
  fi

  
  FILET_REPOSITORIES+=("${repository_path}")
}

use() {
  module="${1}"
  variable_name="${module:u:gs/-/_/}"

  # Only use each module once.
  env_flag="FILET_MODULE_LOADED_${variable_name}"
  if (( ${(P)+env_flag} )); then return; fi
  eval "${env_flag}=yes"
  log_debug "use ${module}"

  module_path=$(resolve_module "${module}")
  eval "FILET_MODULE_ROOT_${variable_name}=${module_path:h}"

  evaluate_script "${module_path}"
}

resolve_module() {
  module="${1}"

  for repository in "${FILET_REPOSITORIES[@]}"; do
    if [[ -f "${repository}"/"${module}"/module.filet ]]; then
      echo "${repository}"/"${module}"/module.filet
      return 0
    elif [[ -f "${repository}"/"${module}".filet ]]; then
      echo "${repository}"/"${module}".filet
      return 0
    fi
  done

  log_error "Unable to locate module {{yellow}}${module}{{/}} via search paths:"
  log_error
  for repository in "${FILET_REPOSITORIES[@]}"; do
    log_error "  ${repository}"
  done
  return 1
}

git_sync() {
  destination="${1:A}"
  url="${2}"
  # TODO
  # refspec="${3}"
  log_debug "git_sync ${url} ${destination}"

  if [[ -d "${destination}"/.git ]]; then
    git -C "${destination}" pull --depth 1 --rebase --quiet
  else
    git clone --depth 1 "${url}" "${destination}"
  fi  
}
