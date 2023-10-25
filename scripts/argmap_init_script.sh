#!/usr/bin/env bash
# shellcheck disable=SC2034
# Turns off unused variable warning, since exports are implicit due to set -o allexport

echo "Running ${BASH_SOURCE[0]}"

export NETLIFY=${NETLIFY:-false}
export ENV=${ENV:-vscode}
export MODE=${MODE:-dev}

# shellcheck source=/home/s6mike/.bashrc
case $NETLIFY in

true)
  make install
  ;;
*)
  source "$HOME/.bashrc"
  # source=/home/s6mike/scripts/default_vscode_init_script.sh # Stops shellcheck lint error
  # source "$HOME/scripts/default_vscode_init_script.sh"
  ;;
esac

# Needed for non-VSCode environments:
# TODO should set to $HOME/local/argmap by default
#   Add check whether $HOME/git_projects/argmap exists, then set as above instead
#   Or use .env file?
set -o allexport
# QUESTION: Change to PATH_DIR_ARGMAP_ROOT?
WORKSPACE=${WORKSPACE:-$HOME/git_projects/argmap}
PATH_DIR_SCRIPTS="$WORKSPACE/scripts"
PATH_FILE_YQ=${PATH_FILE_YQ:-yq}

# shellcheck source=/home/s6mike/git_projects/argmap/scripts/argmap.env
source "$PATH_DIR_SCRIPTS/argmap.env"
set +o allexport

# For trying stuff:
#   source "$WORKSPACE/scripts/experiment.sh"

# shellcheck source=/home/s6mike/git_projects/argmap/scripts/init_read_config.sh
source "$PATH_DIR_SCRIPTS/init_read_config.sh"

# TODO remove stuff covered by `init_read_config.sh`
# Needed for scripts/argmap.env tmp chrome profile:
set -o allexport
DIR_PROJECTS=${DIR_PROJECTS:-$(dirname "$WORKSPACE")}
PATH_MISC_DEV=$DIR_PROJECTS/misc
set +o allexport

# shellcheck disable=SC1091
source "$PATH_DIR_SCRIPTS/bash_aliases_mapjs.sh"

# source "$HOME/scripts/config.env"

# QUESTION move to end of file?
#   TODO: normal install shouldn't use conda, so should set up to give option for either
set -o allexport
CONDA_ENV_ARGMAP="$(getvar CONDA_ENV_ARGMAP)"

# Adds lua folder to start of PATH so lua files called from there instead of /opt/miniconda3/envs/argmap/bin/argmap2mup
#  QUESTION: Combine these?
PATH_DIR_ARGMAP_SRC="$(getvar PATH_DIR_ARGMAP_SRC)"
PATH_DIR_ARGMAP_LUA="$PATH_DIR_ARGMAP_SRC/lua"
PATH="$PATH_DIR_ARGMAP_LUA:$PATH"
# PANDOC - needed for pandoc-argamp.lua until lua reads config directly
PATH_INCLUDES_ARGMAP_CONTAINER_DEFAULT=$(getvar PATH_INCLUDES_ARGMAP_CONTAINER_DEFAULT || getvar PATH_INCLUDES_ARGMAP_CONTAINER)
LUA_PATH=$(getvar LUA_PATH)
# Not sure if this is needed:
LUA_CPATH=$(getvar LUA_CPATH)
PATH_TEST_LOG=$(getvar PATH_TEST_LOG)
set +o allexport

# Covered by default init script
# shellcheck source=/home/s6mike/scripts/bash_aliases.sh # Stops shellcheck lint error
# source "$HOME/scripts/bash_aliases.sh"
# source /opt/miniconda3/bin/activate

# Order of setting variables then activating important?
#   create a (version-controlled) activate.cmd file in the root of the project directory that sets the environemnt variable(s) and then calls conda's own activate.bat script.
# conda activate "$CONDA_ENV_ARGMAP"

# QUESTION: Add cleanup function?
#   https://stackoverflow.com/questions/4632028/how-to-create-a-temporary-directory#answer-34676160

# Uses config file in the relevant mapjs directory to get correct mapjs paths
# shellcheck source=/mapjs/scripts/mapjs.env # Stops shellcheck lint error
source "$(getvar PATH_DIR_MAPJS_ROOT)/scripts/mapjs.env"

source "$WORKSPACE/scripts/bash_aliases_argmap.sh"

# Add pandoc bash completions
eval "$(pandoc --bash-completion)"

# tabtab source for netlify package
# uninstall by removing these lines

# shellcheck source=/dev/null
# shellcheck disable=SC2015
[ -f ~/.config/tabtab/__tabtab.bash ] && . ~/.config/tabtab/__tabtab.bash || true

# Add Nodejs flags:
# Didn't fix type: json import error, leaving for reference.
# export NODE_OPTIONS="--experimental-modules --experimental-json-modules"

case $NETLIFY in

true) ;;
*)
  source "$WORKSPACE/test/test_scripts/bash_aliases_argmap_test.sh"
  ;;
esac

set -o allexport

PATH_PUBLIC=$(getvar PATH_PUBLIC)
PATH_INPUT_PUBLIC=$(getvar PATH_INPUT_PUBLIC)
PATH_OUTPUT_PUBLIC=$(getvar PATH_OUTPUT_PUBLIC)
PATH_LUA_LOCAL=$(getvar PATH_LUA_LOCAL)
PATH_CONVERT_LOCAL=$(getvar PATH_CONVERT_LOCAL)
PATH_PANDOC_LOCAL=$(getvar PATH_PANDOC_LOCAL)

# TODO: Not needed by netlify:
PATH_TEST=$(getvar PATH_TEST)
CONDA_PREFIX=$(getvar CONDA_PREFIX)
PATH_BIN_GLOBAL=$(getvar PATH_BIN_GLOBAL)
PATH_PANDOC_GLOBAL=$(getvar PATH_PANDOC_GLOBAL)
PATH_LUA_GLOBAL=$(getvar PATH_LUA_GLOBAL)

# TODO: rename orig var to PATH_LUA_ARGMAP
PATH_LUA_ARGMAP=$(getvar PATH_DIR_ARGMAP_LUA)

# make site dependencies:
PATH_DIR_MAPJS_ROOT=$(getvar PATH_DIR_MAPJS_ROOT)
PATH_FILE_OUTPUT_EXAMPLE=$(getvar PATH_FILE_OUTPUT_EXAMPLE)
PATH_FILE_OUTPUT_EXAMPLE2_COMPLEX=$(getvar PATH_FILE_OUTPUT_EXAMPLE2_COMPLEX)
PATH_OUTPUT_JS=$(getvar PATH_OUTPUT_JS)

# For `webpack-dist-tags.html` generation.
PATH_FILE_MAPJS_HTML_DIST_TAGS=$(getvar PATH_FILE_MAPJS_HTML_DIST_TAGS)

# For cleaning html output
PATH_OUTPUT_HTML_PUBLIC=$(getvar PATH_OUTPUT_HTML_PUBLIC)
PATH_OUTPUT_MAPJS_PUBLIC=$(getvar PATH_OUTPUT_MAPJS_PUBLIC)
set +o allexport

# QUESTION: Better to define above variables as part of make call instead of exporting them?
make all # --warn-undefined-variables, -d for debugging
