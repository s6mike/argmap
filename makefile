# Makefile for argmap

# make site MODE=prod # To make site in prod mode

# TODO 
#		Add make test
#		Add make help e.g. https://stackoverflow.com/questions/8811526/using-conditional-rules-in-a-makefile

# REVIEW: It is not wise for makefiles to depend for their functioning on environment variables set up outside their control, since this would cause different users to get different results from the same makefile. This is against the whole purpose of most makefiles. #issue #warning #review
#		From https://www.gnu.org/software/make/manual/html_node/Environment.html
#		Currently using many variables like this.
#			QUESTION: What's best practice?

# ###########
# Variables

# Turns off implicit rules etc
MAKEFLAGS += -rR
.SUFFIXES:

# Needed for substitutions to work when calling bash function
SHELL := /bin/bash

# Testing removing this to fix netlify live, but doesn't seem to matter:
# MODE ?= dev # default. Use make MODE=prod or make site for prod mode

# Avoids collisions with filenames
#		-- is convention for private targets
.PHONY: all config public --conda output_clean site_clean clean install npm npm_audit pandoc prints site test # dev

# Define variables
# := simple, assigned once

# 	Need to export required variables at end of argmap_init_script.sh:

#		QUESTION: Could I run getvar from within makefile instead?
LINK_TARGETS_PUBLIC_FOLDERS := ${PATH_OUTPUT_PUBLIC} ${PATH_INPUT_PUBLIC}

LINK_TARGETS_PUBLIC := ${LINK_TARGETS_PUBLIC_FOLDERS}
# Add index.html (should be called locally only
LINK_TARGETS_PUBLIC += ${PATH_PUBLIC}/index.html

# Ensure lua dependencies available to site for client_argmap2mapjs:
# LINK_TARGETS_PUBLIC += ${PATH_PUBLIC}/lua ${PATH_PUBLIC}/lua_modules

LINK_TARGETS_CONDA := ${PATH_LUA_LOCAL}
LINK_TARGETS_CONDA += ${PATH_FILE_CONVERT_LOCAL} # Only needed for pre-commit hook (this is to create png files?)
# Connects legacy data-folder to conda env:
# 	TODO: add this to conda activation, and delete this link when env deactivated?
# 	NOTE: can use defaults file to set defalt data directory, should simplify.
# 	Alternative is always to use --data-directory "$PATH_PANDOC_GLOBAL/" when calling pandoc
LINK_TARGETS_CONDA += ${PATH_PANDOC_LOCAL}

# For vscode pandoc extensions:
#		Currently no link:
#			LINK_TARGETS_CONDA += ${PATH_PANDOC_GLOBAL}/config_argmap.lua
LINK_TARGETS_CONDA += ${PATH_LUA_GLOBAL}/config_argmap.lua
# For calling from shell
LINK_TARGETS_CONDA += ${PATH_BIN_GLOBAL}/argmap2mup
LINK_TARGETS_CONDA += ${PATH_BIN_GLOBAL}/argmap2tikz
LINK_TARGETS_CONDA += ${PATH_BIN_GLOBAL}/mup2argmap
# Adds lua and template files to pandoc data-folder:
LINK_TARGETS_CONDA += ${PATH_PANDOC_GLOBAL}/filters/pandoc-argmap.lua
LINK_TARGETS_CONDA += ${PATH_PANDOC_GLOBAL}/templates/examples/example-template.latex

# DIRS_KEY := test/output mapjs/public/input/mapjs-json mapjs/public/input/markdown # html
# TODO: Use var for mapjs/public/input/markdown etc
FILES_MD = $(shell find test/input/markdown -type f -iname "*.md")
FILES_MAPJS_JSON = $(shell find test/input/mapjs-json -type f -iname "*.json" )
FILES_MAPJS_MUP = $(shell find test/input/mapjs-json -type f -iname "*.mup" )
# FILES_MAPJS_ALL = $(shell find test/input/mapjs-json -type f \( -iname "*.json" -o -iname "*.mup" \) )

# FILES_HTML_FROM_MD := $(foreach file,$(FILES_MD),$(patsubst mapjs/public/input/markdown/%.md,${PATH_OUTPUT_HTML_PUBLIC}/%.html,$(file)))
FILES_HTML_FROM_MD := ${FILES_MD:test/input/markdown/%.md=${PATH_OUTPUT_HTML_PUBLIC}/%.html}

# Can't use above pattern because it includes files which don't match the pattern
FILES_HTML_FROM_JSON := $(patsubst test/input/mapjs-json/%.json,${PATH_OUTPUT_HTML_PUBLIC}/%.html,$(filter %.json,${FILES_MAPJS_JSON}))
FILES_HTML_FROM_JSON += $(patsubst test/input/mapjs-json/%.mup,${PATH_OUTPUT_HTML_PUBLIC}/%.html,$(filter %.mup,${FILES_MAPJS_MUP}))
FILES_HTML_FROM_JSON := $(filter-out ${FILES_HTML_FROM_MD}, ${FILES_HTML_FROM_JSON})

FILES_HTML = $(FILES_SITE) $(FILES_HTML_FROM_JSON) $(FILES_HTML_FROM_MD)
FILES_SITE = ${PATH_FILE_OUTPUT_EXAMPLE} ${PATH_FILE_OUTPUT_EXAMPLE2_COMPLEX}
FILES_TEMPLATE_HTML := src/layouts/templates/pandoc-mapjs-main-html5.html ${PATH_FILE_MAPJS_HTML_DIST_TAGS} src/layouts/includes/argmap-head-element.html src/layouts/includes/argmap-input-widget.html src/layouts/includes/mapjs-map-container.html src/layouts/includes/mapjs-widget-controls.html
FILES_JS := ${PATH_OUTPUT_JS}/main.js ${PATH_OUTPUT_JS}/main.js.map

# Stops intermediate files being deleted (e.g. environment-mapjs.yaml)
# Using .SECONDARY: without arguments breaks things though
# .SECONDARY: $(FILES_MAPJS_JSON) $(FILES_MAPJS_MUP)

# .NOTINTERMEDIATE only supported in make 4.4
.NOTINTERMEDIATE:

# If PATH_PUBLIC is empty, its rule will match anything, so this ensure it always has a value:
# Sets variable if not already defined
PATH_PUBLIC ?= NULL
CONDA_PREFIX ?= NULL
PATH_DIR_MAPJS_ROOT ?= NULL

rockspec_file := $(shell find . -type f -name "argmap-*.rockspec")

# ###########
# Top Level recipes

all: config
# Optional dependencies not used by netlify.
ifneq (${ENV}, netlify)
  all: public --conda lua_modules/
endif

config: ${LIST_FILES_CONFIG_PROCESSED}
public: $(LINK_TARGETS_PUBLIC)

--conda: $(LINK_TARGETS_CONDA)
# -conda activate ${CONDA_ENV_ARGMAP}
# export CONDA_ENV_ARGMAP="argmap"
# export XDG_DATA_HOME="${CONDA_PREFIX}/share/"

# Delete argmap output files only
output_clean:
	$(warning Attempting to delete old test outputs:)
# QUESTION Create bash function for this?
	rm -f ${PATH_FILE_OUTPUT_EXAMPLE}	
	rm -f ${PATH_FILE_OUTPUT_EXAMPLE2_COMPLEX}
	rm -rf ${PATH_OUTPUT_HTML_PUBLIC}
	rm -rf ${PATH_OUTPUT_MAPJS_PUBLIC}
#		TODO: Replace with vars:
	rm -f ${PATH_DIR_ARGMAP_ROOT}/${PATH_OUTPUT_MAPJS_PUBLIC}/mapjs-json/example2-clearly-false-white-swan-v3.mup
# rm -rf ${PATH_DIR_ARGMAP_ROOT}/mapjs/public/output/png
# argmap cleans
	__clean_repo

# Deletes key files so make site can work
#		QUESTION: Can I set logic based on MODE?
site_clean: output_clean
	$(warning Attempting to delete site redirects:)
# Ignores error if public/output is a dir rather than a link:
#		TODO run based on current MODE, plus what's currently present
#			QUESTION: Check whether symlink is present?
	-rm -f $(LINK_TARGETS_PUBLIC)
	rm -rf $(LINK_TARGETS_PUBLIC_FOLDERS)
	rm -rf ${PATH_OUTPUT_JS}
	rm -f ${PATH_FILE_MAPJS_HTML_DIST_TAGS} 

clean: site_clean
	$(warning Attempting to delete everything generated by repo:)
	rm -f $(LINK_TARGETS_CONDA)
# Takes too long to build and breaks things to best not to delete
# delete public/js, lua_modules, node_modules, 
# luarocks remove
# Delete these last since it will stop config var lookups working
	rm -f ${LIST_FILES_CONFIG_PROCESSED}
# rm ${PATH_FILE_GDRIVE_LOCAL}

# dev:
#		QUESTION: Check correct netlify site?
# 	netlify build
# 	make all
# 	netlify dev

install: ${PATH_FILE_YQ} pandoc npm lua_modules/ # TODO: replace npm with npm_audit based on ENV
ifneq (${ENV}, netlify)
  install: ${PATH_FILE_CONVERT_GLOBAL} npm_audit ${PATH_FILE_GDRIVE_LOCAL}
endif

npm: ${MAPJS_NODE_MODULES_PREFIX}/node_modules

npm_audit: | npm npm_audit_output.txt

# netlify version 2.1.3
#	 User data directory: /opt/buildhome/.local/share/pandoc
# QUESTION: Check for existence?
pandoc: 
	-pandoc --version
# if this doesn't exist, create before installing pandoc, so that user data directory should be set automatically:
# @-mkdir --parent ~/.local/share/pandoc/filters
# Though I think I may want to install it in relevant conda env folder instead

# - pandoc==2.12=h06a4308_3
# conda install pandoc https://github.com/jgm/pandoc/blob/main/INSTALL.md

# -chmod 744 ${PATH_FILE_YQ}/pandoc
# If not using conda would need conda dependencies installed.

# ${PATH_BIN_GLOBAL}/luarocks: lua

# lua: ${PATH_BIN_GLOBAL}/luarocks ${PATH_BIN_GLOBAL}/lua5.3 | lua_modules/
# lua: ${PATH_BIN_GLOBAL}/luarocks # ${PATH_BIN_GLOBAL}/lua5.3 # install.sh
# echo "PATH: ${PATH}"
# scripts/qa_rockspec.sh
# update-alternatives --config lua-interpreter
# TODO use variables in linuxbrew path

prints:
	$(info FILES_MD: $(FILES_MD))
	$(info FILES_MAPJS_JSON: ${FILES_MAPJS_JSON})
	$(info FILES_MAPJS_MUP: ${FILES_MAPJS_MUP})
	$(info FILES_HTML_FROM_JSON: ${FILES_HTML_FROM_JSON})
	$(info FILES_HTML_FROM_MD: ${FILES_HTML_FROM_MD})
# $(info PATH_PUBLIC:)
# $(info ${PATH_PUBLIC})
# $(info PATH_TEST:)
# $(info ${PATH_TEST})
# 	$(info LINK_TARGETS_CONDA:)
# 	$(info ${LINK_TARGETS_CONDA})	
	$(info LIST_FILES_CONFIG_PROCESSED:)
	$(info ${LIST_FILES_CONFIG_PROCESSED})
# 	$(info PATH_DIR_CONFIG_MAPJS:)
# 	$(info ${PATH_DIR_CONFIG_MAPJS})
# 	$(info PATH_DIR_CONFIG_MAPJS_PROCESSED:)
# 	$(info ${PATH_DIR_CONFIG_MAPJS_PROCESSED})

# Ensures site_clean only run locally in prod mode (to clean up any dev files)
ifeq (${MODE}, prod)
ifneq (${ENV}, netlify)
site: site_clean $(FILES_SITE)
endif
endif
site: $(FILES_SITE)

# start: site
# start:
# 	./scripts/argmap_init_script.sh

# Using the mapjs file `public/output/mapjs-json/example2-clearly-false-white-swan-v3.json`, plus associated html file renamed as index.html
# - `netlify.toml`: Add redirect from `index.html` to `output/html/index.html`.

# TODO: for building sites, these should write to public folder directly, not via a symbolic link
#		i.e. make site should write to public, make test should write to test output		
# 	Can I do that with a flag or something?

# Instead of: make all,  __clean_repo, and also to remove symlnks
# test: MODE := dev
test: # public site_clean all
# TODO remove output dir and add symlink instead
ifeq (${ENV}, netlify)
	-./test/test_scripts/tests.sh html
else
	./test/test_scripts/tests.sh
endif
	
# Instead of calling webpack_X in tests.sh:
# ${PATH_FILE_MAPJS_HTML_DIST_TAGS} ${PATH_OUTPUT_JS}/main.js:
# webpack_server_start
# __init_tests
# lint rockspec
# Run tests, using wait-on PATH_FILE_MAPJS_HTML_DIST_TAGS
# Print output
# Update repo?

# ###########
# Lower level recipes

## Core functionality

npm_audit_output.txt:
	-npm audit fix --prefix "${PATH_DIR_MAPJS_ROOT}" --legacy-peer-deps >npm_audit_output.txt

${PATH_DIR_MAPJS_ROOT}/package.json:
${PATH_DIR_MAPJS_ROOT}/webpack.config.js:


# Generate html from json
# 	QUESTION Can I combine this with first v3.html rule?
# Call make HTML_OPEN=true to open output file
#	 QUESTION Only set 2hf -s flag in production mode?

# QUESTION: de-duplicate 2hf calls? https://workflowy.com/#/efcfc1a0943d
$(FILES_HTML_FROM_JSON): ${PATH_OUTPUT_HTML_PUBLIC}/%.html: ${PATH_OUTPUT_PUBLIC}/mapjs-json/%.json ${FILES_TEMPLATE_HTML}
# $(info Building $@ from JSON)
	@-mkdir --parent "$(@D)"
# wait for ${PATH_FILE_MAPJS_HTML_DIST_TAGS} to be present before running next line
# make ${PATH_FILE_MAPJS_HTML_DIST_TAGS} && 2hf -ps "$<"
	@if [ "$$HTML_OPEN" = "true" ]; then \
		flags_2hf="-s"; \
	else \
		flags_2hf="-ps"; \
	fi; \
	2hf $$flags_2hf "$<"	

# npx --prefix "${MAPJS_NODE_MODULES_PREFIX}" wait-on --timeout 10000 "${PATH_FILE_MAPJS_HTML_DIST_TAGS}" && 2hf -ps "$<"
# ${PATH_OUTPUT_PUBLIC}/mapjs-json/%.json: ;

# Generate .json from .yaml
${PATH_OUTPUT_PUBLIC}/mapjs-json/%.json: ${PATH_INPUT_LOCAL}/%.yaml
	@-mkdir --parent "$(@D)"
	a2m "$<" "$@"

# Copy .json from input to output, before generating html
${PATH_OUTPUT_PUBLIC}/%.json: ${PATH_INPUT_LOCAL}/%.json
	@-mkdir --parent "$(@D)"
	cp "$<" "$@"

${PATH_OUTPUT_PUBLIC}/%.json: ${PATH_OUTPUT_LOCAL}/%.json
	@-mkdir --parent "$(@D)"
	cp "$<" "$@"

# Copy .mup from input to output, before generating html
${PATH_OUTPUT_PUBLIC}/%.json: ${PATH_INPUT_LOCAL}/%.mup
	@-mkdir --parent "$(@D)"
	cp "$<" "$@"

${PATH_OUTPUT_PUBLIC}/mapjs-json/%_argmap1.json ${PATH_OUTPUT_PUBLIC}/mapjs-json/%_argmap2.json: ${PATH_INPUT_LOCAL}/markdown/%.md
	@-mkdir --parent "$(@D)"
	2hf -ps "$<"

# Generate html from markdown (may have multiple .json dependencies)
# mapjs/public/output/html/example1-clearly-false-white-swan-simplified-2mapjs.html
#		QUESTION: remove ${PATH_INPUT_LOCAL}/markdown/%.md as dependency (since this is called via mapjs-json files) and use pattern instead of "$<"?
$(FILES_HTML_FROM_MD): ${PATH_OUTPUT_HTML_PUBLIC}/%.html: ${PATH_INPUT_LOCAL}/markdown/%.md ${PATH_OUTPUT_PUBLIC}/mapjs-json/%_argmap1.json ${PATH_OUTPUT_PUBLIC}/mapjs-json/%_argmap2.json ${FILES_TEMPLATE_HTML}
# $(info Building $@ from MD)
# Might be able to run pandoc_argmap instead
	@-mkdir --parent "$(@D)"
# && ensures wait for ${PATH_FILE_MAPJS_HTML_DIST_TAGS} to be present before running next line
# make ${PATH_FILE_MAPJS_HTML_DIST_TAGS} && 2hf -ps "$<"
# npx --prefix "${MAPJS_NODE_MODULES_PREFIX}" wait-on --timeout 10000 "${PATH_DIR_MAPJS_ROOT}/${PATH_FILE_MAPJS_HTML_DIST_TAGS}" && 2hf -ps "$<"
	@if [ "$$HTML_OPEN" = "true" ]; then \
		flags_2hf="-s"; \
	else \
		flags_2hf="-ps"; \
	fi; \
	2hf $$flags_2hf "$<"

# Create js dependencies for html files:
${PATH_FILE_MAPJS_HTML_DIST_TAGS} ${PATH_OUTPUT_JS}/main.js ${PATH_OUTPUT_JS}/main.js.map: ${MAPJS_NODE_MODULES_PREFIX}/package.json ${PATH_DIR_MAPJS_ROOT}/webpack.config.js
	$(info make site MODE: ${MODE})
	-mkdir --parent "${@D}"
	-echo "NODE_PATH: ${NODE_PATH}"
	npm run pack:$(MODE) --prefix "${MAPJS_NODE_MODULES_PREFIX}"
	-npx --prefix "${MAPJS_NODE_MODULES_PREFIX}" wait-on --timeout 10000 "${PATH_FILE_MAPJS_HTML_DIST_TAGS}"

## Installation:

### Config:

# Copy env defaults file, but without overwriting existing one. No order pre-requisite to stop repeated copying attempts.
%.yaml: | %-defaults.yaml
	cp --no-clobber $*-defaults.yaml $@

${PATH_FILE_ENV_ARGMAP_PRIVATE}:
	touch $@

# Process config and environment files
# 	QUESTION: Use more variables?
# 	TODO: De-duplicate with mapjs call
${PATH_DIR_CONFIG_ARGMAP_PROCESSED}/%-${KEYWORD_PROCESSED}.yaml: ${PATH_DIR_CONFIG_ARGMAP}/%.yaml scripts/argmap.env
	@-mkdir --parent "$(@D)"
	@preprocess_config "$<" "$@"

# QUESTION add mapjs.env as dependency? 
${PATH_DIR_CONFIG_MAPJS}/${KEYWORD_PROCESSED}/%-${KEYWORD_PROCESSED}.yaml: ${PATH_DIR_CONFIG_MAPJS}/%.yaml
	@-mkdir --parent "$(@D)"
	@preprocess_config "$<" "$@"

### Site output vs test output

# Rule for public links
#  after | is order only pre-requisite, doesn't update based on timestamps
# This is static pattern rule, which restricts rule to match LINK_TARGETS_PUBLIC:
$(LINK_TARGETS_PUBLIC_FOLDERS): ${PATH_PUBLIC}/%: | ${PATH_TEST}/%
	@-mkdir --parent "$(@D)"
# realpath generates path relative to path_public
	-ln -s $(realpath --no-symlinks --relative-to=$(dirname $@) $|) $@

# Makes required folders
# $(DIRS_KEY):
# 	@-mkdir --parent "$(@D)"

# Add index.html (should be called locally only)
${PATH_PUBLIC}/index.html: | ${PATH_FILE_OUTPUT_EXAMPLE}
	@-mkdir --parent "$(@D)"
	-ln -s $(realpath --no-symlinks --relative-to=$(dirname $@) $|) $@

### Other install:

# https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix

# ${PATH_BIN_GLOBAL}/lua5.3: ${PATH_BIN_GLOBAL}/lua-5.3.5
# # $(MAKE) is for recursive make; -C calls make in subfolder	
# # cd $< && $(MAKE) linux test
# # cd $< && make install
# 	$(MAKE) -C $< linux test
# 	$(MAKE) -C $< install

# ${PATH_BIN_GLOBAL}/lua-5.3.5: ${PATH_BIN_GLOBAL}/lua-5.3.5.tar.gz
# 	tar -zxf $<
# # app_path="${app_path%.*}"

# ${PATH_BIN_GLOBAL}/lua-5.3.5.tar.gz:
# 	app_install ${PATH_BIN_GLOBAL} http://www.lua.org/ftp/lua-5.3.5.tar.gz

${PATH_LUA_MODULES}/lib/luarocks: # ${PATH_BIN_GLOBAL}/lua5.3
ifeq (${ENV}, netlify)
# # app_install ${PATH_BIN_GLOBAL} http://www.lua.org/ftp/lua-5.3.5.tar.gz
# 	app_install ${PATH_BIN_GLOBAL} https://luarocks.github.io/luarocks/releases/luarocks-3.7.0-linux-x86_64.zip
# 	-./configure --with-lua-include=/usr/local/include
# 	$(MAKE)
# 	$(MAKE) install
else
# If installing from environment.yaml, skip to SECTION 2.
# conda install -c anaconda lua==5.3.4=h7b6447c_0
	conda install -c anaconda-platform luarocks==3.7.0=lua53h06a4308_0
# TODO for conda, run command to add conda env as dependencies directory (for lib yaml etc) to end of config file: $CONDA_PREFIX/share/lua/luarocks/config-5.3.lua
# QUESTION: Something like this?
# echo "external_deps_dirs = {
#    "$CONDA_PREFIX"
# }" >> "$CONDA_PREFIX/share/lua/luarocks/config-5.3.lua"

# Though LD_LIBRARY_PATH might also work: https://workflowy.com/#/dad8323b9953

# # TODO: for other users would need to install argmap in current directory
# 	chmod 744 "${PATH_DIR_ARGMAP_LUA}/"*
# 	chmod 744 "${PATH_FOLDER_ARGMAP_SRC}/js/"*

# # Can instead remove each package in turn with lua remove name --tree "$install_dir/$dir_lua" (name needs to match rockspec name e.g. penlight not pl)
# #   Might be able to uninstall argamp if I've installed it all rather than just dependencies
#   luarocks remove
endif

# ${MAPJS_NODE_MODULES_PREFIX}/node_modules:
# 	-mkdir --parent "$(@D)"
# # -ln -s $(realpath --no-symlinks --relative-to=$(dirname $@) $|) $@
# # -ln -s "${MAPJS_NODE_MODULES_PREFIX}/node_modules" "${PATH_DIR_MAPJS_ROOT}/node_modules"
# 	-ln -s $@ "${PATH_DIR_MAPJS_ROOT}/node_modules"

${MAPJS_NODE_MODULES_PREFIX}/node_modules: ${MAPJS_NODE_MODULES_PREFIX}/package.json # ${MAPJS_NODE_MODULES_PREFIX}/node_modules
	$(info MAPJS_NODE_MODULES_PREFIX: ${MAPJS_NODE_MODULES_PREFIX})
ifeq (${ENV}, netlify)
# -npm install --prefix "${MAPJS_NODE_MODULES_PREFIX}" -g
	npm install --prefix "${MAPJS_NODE_MODULES_PREFIX}"
else
	npm install --prefix "${PATH_DIR_MAPJS_ROOT}"
endif
	ls "${MAPJS_NODE_MODULES_PREFIX}"

${PATH_FILE_YQ}:
# $(info make PATH_FILE_YQ: ${PATH_FILE_YQ})
# -path=$(app_install ${PATH_BIN_GLOBAL} https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64)
# $(info make path: ${path})
# @-mkdir --parent $$(dirname $@)
# QUESTION: how to execute once go installed? Update PATH?
# 	go install github.com/mikefarah/yq/v4@latest
	-wget -qO $@ https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64
	-chmod 744 ${PATH_FILE_YQ}
	-${PATH_FILE_YQ} --version

# Install lua dependencies
#		Ensure I'm in correct directory e.g. ~/git_projects/argmap/
#		Running qa_rockspec will also install dependencies
lua_modules/: ${PATH_LUA_MODULES}/lib/luarocks
#	TODO: split up this script into separate make actions:
# scripts/qa_rockspec.sh
# ifneq ($(*rockspec_file}, '')
	echo "*** Checking: $(rockspec_file) ***"
	luarocks lint "${rockspec_file}"
ifeq (${ENV}, netlify)
	-ls /opt/build/cache/lua_modules/*
	$(info ************)
	-ls ${PATH_LUA_MODULES}/*
# YAML_LIBDIR=${PATH_LIB_GLOBAL}
	luarocks --tree ${PATH_LUA_MODULES} --lua-dir=${PATH_SHARE_GLOBAL}/opt/lua@5.3 --lua-version=5.3 make --only-deps ${rockspec_file}
	-ls /opt/build/cache/lua_modules/*
	$(info ************)
	-ls ${PATH_LUA_MODULES}/*
else
	luarocks --tree lua_modules --lua-version=5.3 make --only-deps ${rockspec_file} YAML_LIBDIR=${CONDA_PREFIX}/lib/
endif
# endif
# Should be able to distinguish between dev and prod install with npm and thuse choose whether 
# testcafe etc are installed.
# So shouldn't need this:
# # Dev tools
# testcafe:
# ifeq ($(MODE), dev)
# 	npm install -g testcafe
# endif


# Rule for conda links to .local folder
${PATH_PROFILE_LOCAL}/%: | ${CONDA_PREFIX}/%
	@-mkdir --parent "$(@D)"
	-ln -s $| $@

${CONDA_PREFIX}/%:
	@-mkdir --parent "$(@D)"

# For calling lua functions from shell (within conda env)
${PATH_BIN_GLOBAL}/%: | ${PATH_DIR_ARGMAP_ROOT}/${PATH_LUA_ARGMAP}/%.lua
	@-mkdir --parent "$(@D)"
	-ln -s $| $@

# Adds .lua files to pandoc data-folder:

${PATH_PANDOC_GLOBAL}/filters/%: | ${PATH_DIR_ARGMAP_ROOT}/${PATH_LUA_ARGMAP}/%
# Makes the required directories in the path
#		Haven't noticed this happening: If you don't use order-only-prerequisites each modification (e.g. copying or creating a file) 
#		in that directory will trigger the rule that depends on the directory-creation target again!
	@-mkdir --parent "$(@D)"
	-ln -s $| $@

# latex templates e.g. examples/example-template.latex need to be in conda folder:
${PATH_PANDOC_GLOBAL}/templates/%: | ${PATH_DIR_ARGMAP_ROOT}/%
	@-mkdir --parent "$(@D)"
	-ln -s $| $@

# Ensure lua dependencies available to site for client_argmap2mapjs
# ${PATH_PUBLIC}/%: | ${PATH_LUA_ARGMAP}
# 	-ln -s $| $@

# ${PATH_PUBLIC}/%: | ${WORKSPACE}/%
# 	-ln -s $| $@

# -ln -s "$PATH_DIR_ARGMAP_LUA" "$PATH_PUBLIC/lua"
# -ln -s $| "$PATH_PUBLIC/lua_modules"

# For vscode pandoc extensions (1,2,3):

# 1. Fixed issue with vscode-pandoc not finding config_argmap with these links:

# Rule for argmap lua links to conda lua folder
#   Needed for config_argmap, but need to use absolute link
${PATH_LUA_GLOBAL}/%.lua: | ${PATH_DIR_ARGMAP_ROOT}/${PATH_LUA_ARGMAP}/%.lua
	@-mkdir --parent "$(@D)"
	-ln -s $| $@

# Currently no link
# Rule for argmap lua links to conda pandoc folder
# ${CONDA_PREFIX}/share/pandoc/%: | ${PATH_LUA_ARGMAP}/%
# 	@-mkdir --parent "$(@D)"
# 	ln -s $| $@

#  2. Pandoc folder location can be printed (see src/lua/pandoc-hello.lua in branch X?) is location of markdown file, so might be able to do relative links from extensions
# rm /js
# Currently mapjs/public/js is just a directory, so have commented out:
# -ln -s /home/s6mike/git_projects/argmap/mapjs/public/js /js

# 3. Install rockspec in global scope

# rockspec_file=$(_find_rockspec) # Gets absolute path
# Can instead remove each package in turn with lua remove name --tree "$install_dir/$dir_lua" (name needs to match rockspec name e.g. penlight not pl)
#   Might be able to uninstall argamp if I've installed it all rather than just dependencies

# luarocks remove
# luarocks make --only-deps "$rockspec_file" YAML_LIBDIR="$CONDA_PREFIX/lib/"

${PATH_FILE_CONVERT_GLOBAL}: ${PATH_BIN_GLOBAL}/magick
ifneq (${ENV}, netlify)
	conda install imagemagick
endif

# 3. `argmap2mup.lua` and `mup2argmap.lua` also depend on the command line utility [`gdrive`](https://github.com/prasmussen/gdrive) for Google Drive integration. Follow the link for installation instructions. (Note that on linux the 386 version is more likely to work: see <https://github.com/prasmussen/gdrive/issues/597>).
# 	TODO make var for gdrive_2.1.1_linux_386.tar.gz (ideally generate from URL)
${PATH_FILE_GDRIVE_LOCAL}: ${PATH_BIN_LOCAL}/gdrive_2.1.1_linux_386.tar.gz
	app_unzip ${PATH_BIN_LOCAL}/gdrive_2.1.1_linux_386.tar.gz ${PATH_FILE_GDRIVE_LOCAL}

${PATH_BIN_LOCAL}/gdrive_2.1.1_linux_386.tar.gz:
	app_install ${PATH_BIN_LOCAL} https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz

# Though may be covered by conda dependencies:
  # - anaconda/linux-64::luarocks==3.7.0=lua53h06a4308_0
  # - texlive-core
  # - pandoc=2.9.2.1
  # - imagemagick
  # - conda-forge/linux-64::unzip==6.0=h7f98852_3
  # - anaconda/linux-64::yaml==0.2.5=h7b6447c_0
  # - anaconda/linux-64::nodejs==16.13.1=hb931c9a_0
  # - anaconda/linux-64::lua==5.3.4=h7b6447c_0

# brew "libyaml"
# 2. For lyaml, you may need to install [libyaml-dev](https://packages.debian.org/stretch/libyaml-dev) or [yaml (conda)](https://anaconda.org/anaconda/yaml).

# brew "texlive"
# 4. Converting the `tikz` code generated by `argmap2tikz.lua` to PDF requires several `TeX` packages, some of which you may need to install if they are not already available on your system. e.g. `texlive-latex-extra` and `texlive-luatex` from apt-get.
# # lualatex is a LaTeX based format, so in order to use it you have to install LaTeX, not just TeX. So you need at least the Ubuntu texlive-latex-base package.
# # But if you aren't an expert, it's usually better to just install texlive-full to avoid issues later on with missing packages.
# # https://tex.stackexchange.com/questions/630111/install-lualatex-for-use-on-the-command-line
# 	apt-get install texlive-latex-extra
# 	apt-get install texlive-luatex

# 5. `pandoc-argmap.lua` depends on [Pandoc](https://pandoc.org/installing.html)(tested with v2.9.2.1 and v2.6), and on `argmap2lua` and `argmap2tikz.lua`. It also depends on [`pdf2svg`](http://www.cityinthesky.co.uk/opensource/pdf2svg/) for conversion to svg, and [ImageMagick](https://www.imagemagick.org/)'s `convert` for conversion to png.