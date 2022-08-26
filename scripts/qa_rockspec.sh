#!/usr/bin/env bash

# rockspec QA: lints and makes rockspec to ensure it is valid.
# Run in project directory itself, not test project.

# If there is more than 1 rockspec, might run wrong one, or maybe both?
ROCKSPEC_FILE=$(find ~+ -type f -name "argmap-*.rockspec") # Gets absolute path

echo "*** Checking: $ROCKSPEC_FILE ***"

INSTALL_DIR="$DIR_PROJECTS/argmap"
LUA_FOLDER="lua_modules"

luarocks lint "$ROCKSPEC_FILE"

cd "$INSTALL_DIR" || {
  echo "Abandoning QA install."
  exit 1
}

echo -e "***Deleting: $INSTALL_DIR/$LUA_FOLDER ***\n"

rm -R "$LUA_FOLDER"

luarocks --tree "$INSTALL_DIR/$LUA_FOLDER" make --only-deps "$ROCKSPEC_FILE" YAML_LIBDIR="$CONDA_PREFIX/lib/"

# Alternative to using YAML_LIBDIR:
# TODO for conda, run command to add conda env as dependencies directory (for lib yaml etc) to end of config file: $CONDA_PREFIX/share/lua/luarocks/config-5.3.lua
# QUESTION: Something like this?
# echo "external_deps_dirs = {
#    "$CONDA_PREFIX"
# }" >> "$CONDA_PREFIX/share/lua/luarocks/config-5.3.lua"

# Though LD_LIBRARY_PATH might also work: https://workflowy.com/#/dad8323b9953
