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
alias argdb='open-debug $DIR_HTML_SERVER_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs.html'
alias argdb2='open-debug $DIR_HTML_SERVER_OUTPUT/html/example1-clearly-false-white-swan-simplified-2mapjs.html'
alias argdbe='open-debug input/html/legacy-mapjs-example-map.html'

## webpack aliases
alias dmj='diff_mapjs'
alias dfs='diff_staged_file' # dfs package.json package.diff
alias smj='node_stop'
alias bmj='__build_mapjs'
alias rml='__run_mapjs_legacy'
alias pmj='webpack_pack'
# Overwrite aliases from default bash_aliases
# alias wss='npm run server --prefix "$PATH_MJS_HOME"'

# mapjs functions

## browser functions

# TODO try shortcut to run test with chrome headless and check that it's correct: https://workflowy.com/#/8aac548986a4
#   Maybe review mapjs tests.

## webpack functions

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

# mapjs tests

# Diffs current commit to mapjs upstream master: so be sure to be on correct commit.
diff_mapjs() { # dmj all_mapjs_fixes_latest_modified.diff
  DIFF_FILENAME="${1:-$DEFAULT_DIFF_FILENAME}"
  EXCLUSIONS_OUTPUT=()
  EXCLUSIONS_INPUT=(package-lock.json .gitignore docs/CHANGELOG-mapjs.md README.md)
  for e in "${EXCLUSIONS_INPUT[@]}"; do
    EXCLUSIONS_OUTPUT+=("':(exclude)$e'")
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
    BROWSER_TESTCAFE='chrome --no-default-browser-check'
    PATH_REPLAY_SCRIPT=${2:-$DEFAULT_SCRIPT}
  else
    BROWSER_TESTCAFE='chrome:headless --no-default-browser-check'
    PATH_REPLAY_SCRIPT=${1:-$DEFAULT_SCRIPT}
  fi
  # __bisect_init
  echo "PATH_REPLAY_SCRIPT: $PATH_REPLAY_SCRIPT"
  npm --prefix "$PATH_MJS_HOME" run testcafe-command "$BROWSER_TESTCAFE" "$PATH_REPLAY_SCRIPT"
}

__test_mapjs_renders() {
  # Doesn't use $WORKSPACE because it needs to work for legacy mapjs repo too.
  result=$("$HOME/git_projects/argmap/test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp" "$1" "${2:-$PATH_LOG_FILE_EXPECT}" "${3:-$PORT_DEV_SERVER}")
  # Using trailing wildcard match in case any trailing line termination characters accidentally captured, like I did before, so they don't break match.
  # e.g. trailing \r:
  # echo aa$("$HOME/scripts/argmap_test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")b
  # abrue
  if [[ "$result" == "true"* ]]; then
    return 0 # success
  else       # if headless chrome fails to render any map nodes
    return 1 #fail
    echo "Render Failed"
  fi
}

# Deprecated

# Deprecated use webpack_server_start # wss
# If I want to turn off the dev server, call smj
__start_mapjs_webserver() {
  npm --prefix "$PATH_MJS_HOME" run start &
  disown # stops server blocking terminal and ensures that it stays running even after terminal closes.
}

## Deprecated
alias __open-server='open-server'
alias __open-mapjs='open-server'
alias __open-chrome-debug='open-debug'
alias __chrome-attach-mapjs='open-debug'

## Deprecated, use node_stop instead
__stop_mapjs_webserver() { #smj
  npm --prefix "$PATH_MJS_HOME" run stop
}

## Deprecated just use start
alias rmj='__restart_mapjs_webserver'

__restart_mapjs_webserver() { #rmj
  node_stop
  __start_mapjs_webserver
}

## Deprecated, use open-server instead

# For opening html pages in linux browser containing mapjs files
# __open-mapjs() {
#   #   Alternatives:
#   #     Embed JSON directly in html
#   #     https://stackoverflow.com/questions/64140887/how-to-solve-cors-origin-issue-when-trying-to-get-data-of-a-json-file-from-local
#   google-chrome --disable-extensions --hide-crash-restore-bubble --allow-file-access-from-files --no-default-browser-check --window-size=500,720 "http://localhost:$PORT_DEV_SERVER/$1" 2>/dev/null &
#   disown # stops browser blocking terminal and allows all tabs to open in single window.
# }

## Mark functions for export to use in other scripts:
export -f __build_mapjs __start_mapjs_webserver __run_mapjs_legacy #__stop_mapjs_webserver __restart_mapjs_webserver
export -f open-debug
export -f testcafe_run __test_mapjs_renders
