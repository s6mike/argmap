#!/usr/bin/env bash

# mapjs functions and aliases

# Functions beginning with __ are for other scripts. They are not considered part of a public API, and therefore updates may change them without warning.

echo "Running ${BASH_SOURCE[0]}"

# shellcheck source=/home/s6mike/scripts/default_vscode_init_script.sh # Stops shellcheck lint error
source "$HOME/scripts/default_vscode_init_script.sh"

# shellcheck source=/home/s6mike/git_projects/mapjs-git-bisect/scripts/git-bisect.env # Stops shellcheck lint error
# echo "PATH_MJS_HOME: $PATH_MJS_HOME"
source "$DIR_PROJECTS/mapjs-git-bisect/scripts/git-bisect.env"

# mapjs aliases

## browser aliases
alias omj='open-mapjs'
alias argdb='open-debug $DIR_HTML_SERVER_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs.html'
alias argdb2='open-debug $DIR_HTML_SERVER_OUTPUT/html/example1-clearly-false-white-swan-simplified-2mapjs.html'
alias argdbe='open-debug input/html/legacy-mapjs-example-map.html'

## webpack aliases
alias dmj='diff_mapjs'
alias dfs='diff_staged_file' # dfs package.json package.diff
alias bmj='__build_mapjs'
alias rml='__run_mapjs_legacy'
alias wpi='webpack_install'
alias pmj='webpack_pack'
alias wss='webpack_server_start' # Simply runs server
alias wsh='webpack_server_halt'

# mapjs functions

## browser functions

# TODO try shortcut to run test with chrome headless and check that it's correct: https://workflowy.com/#/8aac548986a4
#   Maybe review mapjs tests.

## webpack functions

__check_server_on() { # runs server if it's off
  if [ "$SERVER_ON" != true ]; then
    webpack_server_start
  fi
}

__build_mapjs() { # bmj
  # Deletes webconfig output
  # Convoluted solution, but means I can use relative path from mapjs.env to delete the correct output js directory regardless of mapjs repo used.
  # QUESTION: Better to build delete into package.json script?
  # rm -R "$PATH_MJS_HOME/src/$(dirname "$FILE_MJS_JS")" # Don't think this is necessary
  # TODO - adding --inspect should enable debug mode - but can't get to work.
  webpack_install
  webpack_pack
}

__run_mapjs_legacy() { #rml
  echo "Installing and running legacy mapjs"
  dir_legacy_mapjs=mapjs
  # npm --prefix "$DIR_PROJECTS/mapjs" run stop
  npm --prefix "$DIR_PROJECTS/$dir_legacy_mapjs" install
  npm --prefix "$DIR_PROJECTS/$dir_legacy_mapjs" run pack
  npm --prefix "$DIR_PROJECTS/$dir_legacy_mapjs" run server &
  disown # stops server blocking terminal and ensures that it stays running even after terminal closes.
  wait
  REMEMBER_SERVER_PORT=$PORT_DEV_SERVER
  PORT_DEV_SERVER=9000
  open-debug "$1"
  PORT_DEV_SERVER=$REMEMBER_SERVER_PORT
}

# For opening html pages in linux browser containing mapjs files
open-mapjs() { # omj
  #   Alternatives:
  #     Embed JSON directly in html
  #     https://stackoverflow.com/questions/64140887/how-to-solve-cors-origin-issue-when-trying-to-get-data-of-a-json-file-from-local
  google-chrome --disable-extensions --hide-crash-restore-bubble --allow-file-access-from-files --no-default-browser-check --window-size=500,720 "$1" 2>/dev/null &
  disown # stops browser blocking terminal and allows all tabs to open in single window.
}

# mapjs tests

# Diffs current commit to mapjs upstream master: so be sure to be on correct commit.
diff_mapjs() { # dmj all_mapjs_fixes_latest_modified.diff
  DIFF_FILENAME="${1:-$DEFAULT_DIFF_FILENAME}"
  EXCLUSIONS_OUTPUT=()
  EXCLUSIONS_INPUT=(package-lock.json .gitignore docs/CHANGELOG-mapjs.md README.md)
  for e in "${EXCLUSIONS_INPUT[@]}"; do
    EXCLUSIONS_OUTPUT+=("':(exclude)$e'") # Populates array
  done

  DIFF_COMMAND="git diff --no-color --ignore-all-space e30f8d835e028febe2e951e422c313ac304a0431 HEAD -- . ${EXCLUSIONS_OUTPUT[*]} >$DIFF_FILENAME"
  # git diff --no-color e30f8d835e028febe2e951e422c313ac304a0431 HEAD -- . ':(exclude)package-lock.json' ':(exclude).gitignore' ':(exclude)docs/CHANGELOG-mapjs.md' >../diffs/all_mapjs_fixes_latest.diff
  # echo "$DIFF_COMMAND"
  eval "$DIFF_COMMAND" # >../diffs/all_mapjs_fixes_latest.diff"
  code "$DIFF_FILENAME"
}

diff_staged_file() { # dfs package.json package.diff
  INPUT_FILE=${1:-package.json}
  OUTPUT_FILENAME=$(basename "${INPUT_FILE%.*}.diff")
  OUTPUT_FILE=../diffs/${2:-$OUTPUT_FILENAME}
  git diff --cached --no-color --ignore-all-space "$INPUT_FILE" >"$OUTPUT_FILE"
  code "$OUTPUT_FILE"
}

testcafe_run() { # tcr
  DEFAULT_SCRIPT="$PATH_REPLAY_SCRIPT"
  if [ "$1" == head ]; then
    # TODO: Add option to use --speed 0.1
    BROWSER_TESTCAFE='chrome --speed 0.1 --no-default-browser-check --disable-extensions'
    PATH_REPLAY_SCRIPT=${2:-$DEFAULT_SCRIPT}
  else
    # Try timing speed and then compare with using: --experimental-proxyless
    BROWSER_TESTCAFE='chrome:headless --no-default-browser-check --disable-extensions'
    PATH_REPLAY_SCRIPT=${1:-$DEFAULT_SCRIPT}
  fi
  # __bisect_init
  echo "PATH_REPLAY_SCRIPT: $PATH_REPLAY_SCRIPT"
  npm --prefix "$PATH_MJS_HOME" run testcafe:command "$BROWSER_TESTCAFE" "$PATH_REPLAY_SCRIPT"
}

__test_mapjs_renders() {
  __check_server_on
  # Doesn't use $WORKSPACE because it needs to work for legacy mapjs repo too.
  result=$("$HOME/git_projects/argmap/test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp" "$1" "${2:-$PATH_LOG_FILE_EXPECT}" "${3:-$PORT_DEV_SERVER}")
  # Using trailing wildcard match in case any trailing line termination characters accidentally captured, like I did before, so they don't break match.
  # e.g. trailing \r:
  # echo aa$("$HOME/scripts/argmap_test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")b
  # abrue
  if [[ "$result" == "true"* ]]; then
    return 0 # success
  else       # if headless chrome fails to render any map nodes
    echo "Render Failed"
    return 1 #fail
  fi
}

# Start webpack after git checkout
webpack_install() { # wpb
  # Should only install new stuff. Should install in local folder if its set
  npm install --prefix "$PATH_MJS_HOME" # --force
  # TODO: But can also monitor package.json for changes and install automatically instead: https://workflowy.com/#/f666070d7b23
  # wait &&
  # npm exec webpack # Shouldn't be needed if webpack server does it automatically
}

webpack_pack() { #pmj
  npm --prefix "$PATH_MJS_HOME" run pack
}

webpack_server_halt() { #wsh
  npm --prefix "$PATH_MJS_HOME" run stop
  SERVER_ON=false
}

# Starts server
webpack_server_start() { # wss
  export SERVER_ON=true
  if npm --prefix "$PATH_MJS_HOME" run start; then
    true
  else
    SERVER_ON=false
  fi
  # & disown
}

## Mark functions for export to use in other scripts:
export -f __check_server_on __build_mapjs __run_mapjs_legacy open-mapjs
export -f webpack_install webpack_pack webpack_server_start # webpack_pack_open webpack_build_open
export -f open-debug
export -f testcafe_run __test_mapjs_renders
