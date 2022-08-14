#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# TODO: normal install shouldn't use conda, so should set up to give option for either

# TODO: should parameterize bash_aliases script path

# Needed for non-VSCode environments:
export WORKSPACE=${WORKSPACE:-/home/s6mike/git_projects/argmap}

source "$WORKSPACE/scripts/conda.env" # Get CONDA_ENV_ARGMAP
source /home/s6mike/scripts/bash_aliases.sh
source /opt/miniconda3/bin/activate

# Order of setting variables then activating important?
#   create a (version-controlled) activate.cmd file in the root of the project directory that sets the environemnt variable(s) and then calls conda's own activate.bat script.
conda activate "$CONDA_ENV_ARGMAP"
export ENV_FILE="$WORKSPACE/environment.yml"

# Uses variable set in conda env, or defaults to pwd.
# TODO: this still isn't great, assumes you are in argmap folder when called.
#   Plus they will outlast any env deactivation
PROJECT_DIR=$(dirname "$WORKSPACE")
export PROJECT_DIR
export PANDOC_DATA_DIR="$CONDA_PREFIX/share/pandoc"

# This is abolute for reading/writing to the correct directory
export DIR_HTML_OUTPUT="$WORKSPACE/test/output"

# For html links, use relative paths (to test/output folder) - more portable
export DIR_MJS_JSON="mapjs-json"
export PATH_MJS_JSON="$DIR_HTML_OUTPUT/$DIR_MJS_JSON"

# export PATH_MJS_HOME="$WORKSPACE/mapjs-example"
export PATH_MJS_HOME="$WORKSPACE/mapjs"

# Uses config file in the relevant mapjs directory to get correct mapjs paths
# shellcheck source=/mapjs/scripts/mapjs.env # Stops shellcheck lint error
# shellcheck source=/mapjs-example/scripts/mapjs.env # Stops shellcheck lint error
source "$PATH_MJS_HOME/scripts/mapjs.env"

source "$WORKSPACE/scripts/bash_aliases_argmap.sh"

# Add pandoc bash completions
eval "$(pandoc --bash-completion)"

# Add Nodejs flags:
# Didn't fix type: json import error, leaving for reference.
# export NODE_OPTIONS="--experimental-modules --experimental-json-modules"

# QUESTION: Build mapjs just in case?
# __build_mapjs

# TESTING INIT

# TODO: could move to separate test/init_script_argmap_test file
export INPUT_FILE_YML=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified.yml
export INPUT_FILE_JSON=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified.json
export INPUT_FILE_MD0=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified_0mapjs.md
export INPUT_FILE_MD=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs.md
export INPUT_FILE_MD2=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified_2mapjs.md
export INPUT_FILE_MD_META=$WORKSPACE/test/input/Example1_ClearlyFalse_WhiteSwan_simplified_meta_mapjs.md
# export INPUT_FILE_JSON=$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.json

source "$WORKSPACE/test/bash_aliases_argmap_test.sh"
