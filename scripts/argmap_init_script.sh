#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# shellcheck source=/home/s6mike/scripts/default_vscode_init_script.sh # Stops shellcheck lint error
# source "$HOME/scripts/default_vscode_init_script.sh"

# Needed for non-VSCode environments:
export WORKSPACE=${WORKSPACE:-$HOME/git_projects/argmap}
source "$WORKSPACE/scripts/argmap.env"

source "$WORKSPACE/scripts/bash_aliases_mapjs.sh"

# source "$HOME/scripts/config.env"

# TODO: normal install shouldn't use conda, so should set up to give option for either

# TODO: should parameterize bash_aliases script path
# shellcheck source=/home/s6mike/git_projects/argmap/scripts/conda.env # Stops shellcheck lint error
source "$WORKSPACE/scripts/conda.env" # Get CONDA_ENV_ARGMAP

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
# shellcheck source=/mapjs-example/scripts/mapjs.env # Stops shellcheck lint error
# source "$PATH_MJS_HOME/scripts/mapjs.env"

source "$WORKSPACE/scripts/bash_aliases_argmap.sh"

# Add pandoc bash completions
eval "$(pandoc --bash-completion)"

# Add Nodejs flags:
# Didn't fix type: json import error, leaving for reference.
# export NODE_OPTIONS="--experimental-modules --experimental-json-modules"

# QUESTION: Build mapjs just in case?
# __build_mapjs

source "$WORKSPACE/test/test_scripts/bash_aliases_argmap_test.sh"
