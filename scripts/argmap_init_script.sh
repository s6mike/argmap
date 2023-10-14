#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# shellcheck source=/home/s6mike/scripts/default_vscode_init_script.sh # Stops shellcheck lint error
# source "$HOME/scripts/default_vscode_init_script.sh"

# Needed for non-VSCode environments:
# TODO should set to $HOME/local/argmap by default
#   Add check whether $HOME/git_projects/argmap exists, then set as above instead
#   Or use .env file?
export WORKSPACE=${WORKSPACE:-$HOME/git_projects/argmap}
export PATH_DIR_SCRIPTS="$WORKSPACE/scripts"

# For trying stuff:
#   source "$WORKSPACE/scripts/experiment.sh"

# shellcheck source=/home/s6mike/git_projects/argmap/scripts/init_read_config.sh
source "$PATH_DIR_SCRIPTS/init_read_config.sh"

# TODO remove stuff covered by `init_read_config.sh`
# Needed for scripts/argmap.env tmp chrome profile:
DIR_PROJECTS=$(dirname "$WORKSPACE")
export DIR_PROJECTS
export PATH_MISC_DEV=$DIR_PROJECTS/misc

# shellcheck source=/home/s6mike/git_projects/argmap/scripts/argmap.env
source "$PATH_DIR_SCRIPTS/argmap.env"
# shellcheck disable=SC1091
source "$PATH_DIR_SCRIPTS/bash_aliases_mapjs.sh"

# source "$HOME/scripts/config.env"

# TODO: normal install shouldn't use conda, so should set up to give option for either

CONDA_ENV_ARGMAP="$(getvar CONDA_ENV_ARGMAP)"
export CONDA_ENV_ARGMAP

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

source "$WORKSPACE/test/test_scripts/bash_aliases_argmap_test.sh"
