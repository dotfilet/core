# Script Environment

import() {
  local repository="${1}"

  if [[ "${repository}" =~ ^github: ]]; then
    import_git "https://github.com/${repository:7}"
  elif [[ -d "${repository}" ]]; then
    import_path "${repository}"
  else
    fail "Not able to resolve repository {{yellow}}${repository}{{/}} to import"
  fi
}

import_git() {
  local url="${1}"
  local relative_path="${url:8}" # assuming https://…
  local cache_dir="${FILET_STATE_DIR}/repositories/${relative_path}"

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
  local repository_path="${1:A}"

  log_debug "import ${repository_path}"

  if [[ ! -d "${repository_path}" ]]; then
    fail "Unable to import unknown directory {{magenta}}${repository_path}{{/}} ({{magenta}}${repository_path}{{/}})"
  fi
  
  FILET_REPOSITORIES+=("${repository_path}")
}

use() {
  local module="${1}"
  local variable_name="${${module//[.\/-]/_}:u}"

  # Only use each module once.
  env_flag="FILET_MODULE_LOADED_${variable_name}"
  if (( ${(P)+env_flag} )); then return; fi
  eval "${env_flag}=yes"
  log_debug "use ${module}"

  module_path=$(resolve_module "${module}")
  eval "FILET_MODULE_ROOT_${variable_name}=${module_path:h}"

  evaluate_script "${module_path}"
}

resolve_module() (
  local module="${1}"

  if [[ "${module}" =~ ^".+/" ]]; then
    cd "${FILET_CURRENT_MODULE_ROOT}"
    local full_path="${module:A}"
    cd -

    if [[ -f "${full_path}"/module.filet ]]; then
      echo "${full_path}"/module.filet
      return 0
    elif [[ -f "${full_path}".filet ]]; then
      echo "${full_path}".filet
      return 0
    else
      log_error "The local module ${module} must exist at either:"
      log_error
      log_error "  ${full_path}/module.filet"
      log_error "  ${full_path}.filet"
      return 1
    fi
  fi

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
)

git_sync() (
  local destination="${1:A}"
  local url="${2}"

  log_debug "git_sync ${url} ${destination}"

  if [[ -d "${destination}"/.git ]]; then
    git -C "${destination}" pull --depth 1 --rebase --quiet
  else
    git clone --depth 1 "${url}" "${destination}"
  fi  
)

copy() (
  local destination="${1:A}"
  local source="${2}"

  if [[ "${source}" == "" ]]; then
    if [[ "${destination}" == "$HOME"/* ]]; then
      source="./${destination#"$HOME"/}"
    else
      fail "please provide a path to the file to copy (relative to the module)"
    fi
  fi

  cd "${FILET_CURRENT_MODULE_ROOT}"
  source="${source:A}"
  cd -

  log_debug "copy ${destination} <- ${source}"

  cp -rf "${source}" "${destination}"
)
