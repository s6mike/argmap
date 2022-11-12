#!/usr/bin/env bash

# To install with conda, provide first argument conda:
# ./install.sh conda

# SECTION 0:
# ----------

# a) Review: intialised values in `scripts/argmap_init_script.sh`

# SECTION 1:
# ----------

# If installing from environment.yml, skip to SECTION 2.

# TODO: check whether these are already installed
# conda install lua5.3

# conda install -c anaconda-platform luarocks

# TODO for conda, run command to add conda env as dependencies directory (for lib yaml etc) to end of config file: $CONDA_PREFIX/share/lua/luarocks/config-5.3.lua
# QUESTION: Something like this?
# echo "external_deps_dirs = {
#    "$CONDA_PREFIX"
# }" >> "$CONDA_PREFIX/share/lua/luarocks/config-5.3.lua"

# Though LD_LIBRARY_PATH might also work: https://workflowy.com/#/dad8323b9953

# Install lua dependencies

# Ensure I'm in correct directory e.g. ~/git_projects/argmap/

# Running qa_rockspec will also install dependencies
scripts/qa_rockspec.sh

# if this doesn't exist, create before installing pandoc, so that user data directory should be set automatically:
# mkdir --parent ~/.local/share/pandoc/filters
# Though I think I may want to install it in relevant conda env folder instead

# conda install pandoc

# If not using conda would need conda dependencies installed.

# check the version and user data directory, which should be /home/s6mike/.local/share/pandoc/filters
# though I prob want it to be in conda install instead
pandoc --version

# lualatex is a LaTeX based format, so in order to use it you have to install LaTeX, not just TeX. So you need at least the Ubuntu texlive-latex-base package.
# But if you aren't an expert, it's usually better to just install texlive-full to avoid issues later on with missing packages.
# https://tex.stackexchange.com/questions/630111/install-lualatex-for-use-on-the-command-line
apt-get install texlive-latex-extra
apt-get install texlive-luatex

# TODO: for other users would need to install argmap in current directory

chmod u+x src/*

# Link up pre-commit hook
ln -s "$WORKSPACE/scripts/git_hooks/pre-commit" "$WORKSPACE/.git/hooks/"
chmod +x git_hooks/*

# Link up tests.sh to deprecated location?
# ln -s test/test_scripts/tests.sh scripts

# This section only executed if called with first argument 'conda'
# e.g.
#     ./install.sh conda
if [ "$1" == 'conda' ]; then

  # Note: this used to be section 1
  # SECTION 2 Set up conda env:
  # ----------

  # TODO: normal install shouldn't use conda, so should set up to give option for either
  # ie  INSTALL_ROOT=$CONDA_PREFIX||X or similar.

  # Download/install git folder?

  export CONDA_ENV_ARGMAP="argmap"
  export XDG_DATA_HOME="$CONDA_PREFIX/share/"

  # TODO Just run conda env script?
  # if in folder with environment.yml
  # conda env create
  # Else:
  # conda env create -f environment.yml
  # Or:
  # conda env update --file environment.yml --prune --name $CONDA_ENV_ARGMAP

  # If conda activate errors:
  # conda init bash
  # source /opt/miniconda3/bin/activate

  # conda activate $CONDA_ENV_ARGMAP

  # SECTION 3: Link conda env
  # ---------------------------------------------------

  # a) Review: intialised values in `environment.yml`

  # ln -s source_file symbolic_link
  ln -s "$WORKSPACE/src/argmap2mup.lua" "$CONDA_PREFIX/bin/argmap2mup"
  ln -s "$WORKSPACE/src/argmap2tikz.lua" "$CONDA_PREFIX/bin/argmap2tikz"
  ln -s "$WORKSPACE/src/mup2argmap.lua" "$CONDA_PREFIX/bin/mup2argmap"

  # pandoc data-folder:
  # local: ~/.local/share/pandoc/
  #   e.g. ~/.local/share/pandoc/filters
  # legacy: ~/.pandoc/
  # conda: "$CONDA_PREFIX/share/pandoc/filters"

  # This might be useful on more recent version of pandoc, which might actually check all these folders
  # Though more likely it will use XDG_DATA_HOME which I can then overwrite
  # XDG_DATA_DIRS="$CONDA_PREFIX/share":$XDG_DATA_DIRS

  # Adds .lua files to pandoc data-folder:

  # ln -s "$WORKSPACE/src/config_argmap.lua" "$CONDA_PREFIX"/share/pandoc/

  mkdir --parent "$CONDA_PREFIX/share/pandoc/filters/"
  ln -s "$WORKSPACE/src/pandoc-argmap.lua" "$CONDA_PREFIX/share/pandoc/filters/"

  # TODO is this necessary? Forget why
  # ln -s "$WORKSPACE/src/argmap2mup.lua" "$CONDA_PREFIX/share/pandoc/"

  # Add config_argmap file to standard LUA_PATH so easy to update LUA_PATH etc for lua scripts
  # Need to use sudo for both:
  # Uninstalling the main (apt-get) lua might have removed /usr/local.. from LUA_PATH, since vscode-pandoc was suddenly throwing errors.
  # So these shouldn't be needed any longer:
  # mkdir --parents /usr/local/share/lua/5.3/
  # ln -s "$WORKSPACE/src/config_argmap.lua" /usr/local/share/lua/5.3/

  # Fixed issue with vscode-pandoc not finding config_argmap with this link:
  ln -s "$WORKSPACE/src/config_argmap.lua" "$CONDA_PREFIX/share/lua/5.3"

  # latex templates e.g. examples/example-template.latex need to go here:
  mkdir --parent "$CONDA_PREFIX/share/pandoc/templates/examples/"
  ln -s "$WORKSPACE/examples/example-template.latex" "$CONDA_PREFIX/share/pandoc/templates/examples/example-template.latex"

  # Connects legacy data-folder to conda env:
  # TODO: add this to conda activation, and delete this link when env deactivated?
  # NOTE: can use defaults file to set defalt data directory, should simplify.
  # Alternative is always to use --data-directory "$CONDA_PREFIX/share/pandoc/" when calling pandoc
  ln -s "$CONDA_PREFIX/share/pandoc" "$HOME/.local/share/pandoc"

  # Makes conda exes available in local for VSCode extensions which don't have path option:
  # Unnecessary for extensions which have custom pandoc path setting, though vscode-pandoc still throws an error message:
  # ln -s "$CONDA_PREFIX/bin/pandoc" "$HOME/.local/bin/"

  # Added since after uninstalling global lua, vscode-pandoc extension fails.
  # Wondering if adding this link (from section 2), would help:
  #   ln -s "$WORKSPACE/src/config_argmap.lua" "$CONDA_PREFIX"/share/pandoc/

  ln -s "$CONDA_PREFIX/bin/lua" "$HOME/.local/bin/"

  # Only needed for pre-commit hook:
  ln -s "$CONDA_PREFIX/bin/convert" "$HOME/.local/bin/"

  # Install testcafe
  npm install -g testcafe

fi

# SECTION 4: mapjs
# ---------------------------------------------------

# # Check $PATH_MJS_HOME is set as desired
# cd "$PATH_MJS_HOME" || {
#   echo "Abandoning QA install."
#   exit 1
# }

# TODO Use env variables instead of hardcoded folders
# Create json and png output folders otherwise pandoc-argmap.lua won't work
mkdir --parent "$WORKSPACE/test/output/mapjs-json"
mkdir --parent "$WORKSPACE/test/output/png"
mkdir --parent "$WORKSPACE/test/output/html"

# For dev web server:
# Link up test/output and test/input with mapjs/site
ln -s "$DIR_PUBLIC_OUTPUT" "$PATH_MJS_SITE/."
ln -s "$DIR_HTML_INPUT" "$PATH_MJS_SITE/."

# Add index.html
ln -s "$PATH_MJS_SITE/$PATH_INPUT_FILE_HTML" "$PATH_MJS_SITE/index.html"

#nodejs installed with conda

# TODO: remove this comment, now irrelevant?
# Before npm install:
# Check mapjs/package.json, ensure latest git commit is referenced:
# "dependencies": {
#     "mindmup-mapjs": "git@github.com:mindmup/mapjs.git#e30f8d835e028febe2e951e422c313ac304a0431"
#   }

# QUESTION: Do I need above cd if I'm using prefix?
npm --prefix "$PATH_MJS_HOME" install
npm audit fix --prefix "$PATH_MJS_HOME" --legacy-peer-deps >npm_audit_output.txt

__build_mapjs

# SECTION 5: Clientside Lua
# ---------------------------------------------------

# Ensures fengari script and source map available to site
ln -s "$WORKSPACE/src/js/fengari-web.js" "$PATH_MJS_SITE/js/fengari-web.js"
ln -s "$WORKSPACE/src/js/fengari-web.js.map" "$PATH_MJS_SITE/js/fengari-web.js.map"
# Ensure lua dependencies available to site
ln -s "$WORKSPACE/src" "$PATH_MJS_SITE/lua"
ln -s "$WORKSPACE/lua_modules" "$PATH_MJS_SITE/lua_modules"
