#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# To test: test_getvar

# aliases
alias cv='checkvar_exists'
alias gv='getvar'
alias gvy='__getvar_yaml_any'
alias pc='preprocess_config'

export PATH_FILE_ENV_ARGMAP=$WORKSPACE/config/environment-argmap.yml

# Replace echo with this where not piping output
log() {
  printf "%s\n" "$*" >&2
}

__check_exit_status() {
  exit_status=$1
  result=$2
  # log exit_status: "$exit_status"
  if [[ $exit_status == 0 ]]; then
    echo "$result"
  fi
  return "$exit_status"
}

# Alternative: compgen -v | grep full match?
checkvar_exists() {
  [[ -v $1 ]]
}

# This is used to get yaml data, all other config reading functions call it.
#   REMEMBER: ${VARS} are only expanded if they are already bash env variables, otherwise they are left blank.
__getvar_from_yaml() { # __getvar_from_yaml (-el) PATH_FILE_CONFIG_MJS $PATH_FILE_ENV_ARGMAP
  query_rest=" | ...comments=\"\" | select( . != null and . != \"*\${*}*\")"

  OPTIND=1
  while getopts ":el" option; do # Leading ':' removes error message if no recognised options
    case $option in
    e) # env mode - interpolates env variables
      local query_rest=" | ...comments=\"\" | select( . != null) | to_yaml | envsubst(nu,ne) | select( . != \"*\${*}*\")"
      ;;
    l) # list mode - returns a list in argument format
      query_list="| .[]"
      ;;
    *) ;;
    esac
  done

  shift "$((OPTIND - 1))"

  variable_name="$1"
  files=("${@:2}") # Takes 2nd argument onwards and uses them all as yaml files
  yaml_source=("${files[@]:-$PATH_FILE_ENV_ARGMAP}")

  # For this yq: https://github.com/kislyuk/yq, which is on conda
  # result=${!variable_name:-$(yq -r --exit-status --yml-out-ver=1.2 ".$variable_name | select( . != null)" $PATH_FILE_ENV_ARGMAP $PATH_FILE_CONFIG_MJS $PATH_FILE_CONFIG_ARGMAP)}

  # Have set to exclude results with $ in them
  # result=$(yq -r --exit-status --no-doc ".$variable_name | ...comments=\"\" | select( . != null) | to_yaml | envsubst(nu,ne) | select( . != \"*\${*}*\")" "${yaml_source[@]}")
  result=$(yq -r --exit-status --no-doc ".$variable_name $query_rest $query_list" "${yaml_source[@]}")

  __check_exit_status $? "$result"
  # TODO if it fails, can I check whether unset variable is available in yaml, then run again?
}

# Looks up each argument in yaml and exports it as env variable
__yaml2env() { # __yaml2env PATH_FILE_CONFIG_MJS
  yaml_file=${1:-PATH_FILE_ENV_ARGMAP}
  shift
  for env_var_name in "$@"; do
    env_var_value=$(__getvar_from_yaml -e "$env_var_name" "$yaml_file")
    # log "$env_var_name=$env_var_value"
    export "$env_var_name"="$env_var_value"
  done
}

# TODO: Deprecate PATH_MJS_HOME in favour of PATH_DIR_MJS
# __yaml2env "$PATH_FILE_ENV_ARGMAP" PATH_DIR_CONFIG PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR PATH_FILE_CONFIG_PROCESSED_VARIABLES DIR_MJS DIR_PUBLIC PATH_DIR_MJS PATH_FILE_ENV_MAPJS PATH_FILE_ENV_ARGMAP_PRIVATE PATH_MJS_HOME PATH_FILE_CONFIG_ARGMAP PATH_FILE_CONFIG_MJS PATH_FILE_CONFIG_MJS PATH_FILE_CONFIG_ARGMAP PATH_FILE_ENV_CONDA
__yaml2env "$PATH_FILE_ENV_ARGMAP" PATH_DIR_CONFIG PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR

# log "PATH_DIR_CONFIG: $PATH_DIR_CONFIG"
# log "PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR: $PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR"

count_characters() {
  target_config_file=$1
  char=${2:-'$'}
  tr -cd "$char" <"$target_config_file" | wc -c
}

# TODO: combine all non PRIVATE processed variables into one file
# TODO could even build defaults file from template referencing other variables, using this function?
preprocess_config() { # pc /home/s6mike/git_projects/argmap/config/config-argmap.yml
  target_config_file=${1:-$PATH_FILE_ENV_ARGMAP}
  # Strips yaml extension then adds on this one:
  output_file=${target_config_file%%.*}-processed.yaml

  # This gets key value pairs with $, but omits nested $var values (e.g. LIST_FILES_CONFIG)
  #   with_entries(select(.value == "*$*"))'
  # This gets nested key value pairs:
  #  'with_entries(select(.value.[] == "*$*"))'
  # Think this solves it (but won't go deeper than 1 list level)
  yq_query='...comments="" | with_entries(select(.value == "*$*" or .value.[] == "*$*"))'
  yq -r --exit-status "$yq_query" "$target_config_file" >"$output_file"
  # TODO if no values found then quit

  # This line create new file, comment it out and output file will be expanded version of original
  target_config_file="$output_file"

  # Loops until no $vars left
  #   OPTIONAL or until processing doesn't reduce dollars.
  #     Though that might be too strict since it's possible expanding a $ may return another $ and then count will stay the same. In which case need to count a few repeated loops
  while
    dollar_count=$(count_characters "$target_config_file" '$')
    # log "$dollar_count"
    [[ "$dollar_count" -gt 0 ]] # && [ "$dollar_count" != "$prev_dollar_count" ]; do
  do
    # QUESTION: simpler option than pandoc?
    pandoc /dev/null --output="$output_file" --template="$target_config_file" --defaults="$PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR" || return 1

    target_config_file="$output_file"
    # prev_dollar_count="$dollar_count"
  done
  # REVIEW: Might be redundant now:
  if [[ "$target_config_file" == "$output_file" ]]; then
    echo "$output_file"
  fi
}

# log "1*************"
# log "PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR: $PATH_FILE_PANDOC_DEFAULT_CONFIG_PREPROCESSOR"
# # PATH_FILE_CONFIG_PROCESSED_VARIABLES=$(preprocess_config "$PATH_FILE_ENV_ARGMAP")
PATH_FILE_CONFIG_PROCESSED_VARIABLES=$(preprocess_config "$PATH_FILE_ENV_ARGMAP")
export PATH_FILE_CONFIG_PROCESSED_VARIABLES
# log "PATH_FILE_CONFIG_PROCESSED_VARIABLES: $PATH_FILE_CONFIG_PROCESSED_VARIABLES"
# # __yaml2env LIST_FILES_CONFIG
# log "5*************"
# __yaml2env "$PATH_FILE_CONFIG_PROCESSED_VARIABLES" LIST_FILES_CONFIG
# readarray YAML_FILES < <(yq -r '.LIST_FILES_CONFIG[] | envsubst(nu,ne)' "$PATH_FILE_ENV_ARGMAP")
# YAML_FILES="$(yq -r '.LIST_FILES_CONFIG[] | envsubst(nu,ne)' "$PATH_FILE_ENV_ARGMAP")"
# export YAML_FILES

LIST_FILES_CONFIG=$(__getvar_from_yaml -l LIST_FILES_CONFIG "$PATH_FILE_CONFIG_PROCESSED_VARIABLES")
# log "6*************"
# log "LIST_FILES_CONFIG: $LIST_FILES_CONFIG"
# log "7*************"
__getvar_yaml_any() { # gvy
  # log "YAML_FILES: $LIST_FILES_CONFIG"
  set -f # I don't want globbing, but I don't want to quote it because I do want word splitting
  # shellcheck disable=SC2068 # Quoting ${YAML_FILES[@]} stops it expanding
  __getvar_from_yaml "$@" ${LIST_FILES_CONFIG[@]}
  set +f
}

# TEST: test_getvar()
getvar() { # gq PATH_FILE_CONFIG_MJS
  variable_name=$1
  # First checks whether env variable exists
  if checkvar_exists "$variable_name"; then
    result=${!variable_name}
  else
    result=$(__getvar_yaml_any "$variable_name")
    # TODO cache with env variable?
    #   export "$variable_name"="$result"
  fi
  __check_exit_status $? "$result"
}

export -f __check_exit_status checkvar_exists __getvar_from_yaml __getvar_yaml_any __yaml2env getvar

# TODO: remove
# log "8*************"
# gvy LIST_FILES_CONFIG
# unset DIR_PROJECTS
# gvy PATH_MISC_DEV
