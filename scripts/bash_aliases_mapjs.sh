#!/usr/bin/env bash

# mapjs functions and aliases

# Functions beginning with __ are for other scripts. They are not considered part of a public API, and therefore updates may change them without warning.

echo "Running ${BASH_SOURCE[0]}"

# shellcheck source=/home/s6mike/scripts/default_vscode_init_script.sh # Stops shellcheck lint error
source "$HOME/scripts/default_vscode_init_script.sh"

# shellcheck source=/home/s6mike/git_projects/argmap/mapjs/scripts/mapjs.env # Stops shellcheck lint error
source "$PATH_MJS_HOME/scripts/mapjs.env"

# mapjs aliases

## browser aliases
alias argdb='open-debug'
alias argdb1='open-debug $DIR_HTML_SERVER_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs.html'
alias argdbe='open-debug output/example-map.html'

## webpack aliases
alias smj='node_stop'
alias bmj='__build_mapjs'
alias rml='__run_mapjs_legacy'
# Overwrite aliases from default bash_aliases
alias wss='npm run start --prefix "$PATH_MJS_HOME"'

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
  xdg-open "http://localhost:9000/$1"
}

# mapjs tests

function __test_mapjs_renders() {
  RENDERS=$("$WORKSPACE/test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")
  # Using trailing wildcard match in case any trailing line termination characters accidentally captured, like I did before, so they don't break match.
  # e.g. trailing \r:
  # echo aa$("$HOME/scripts/argmap_test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")b
  # abrue
  if [[ "$RENDERS" == "true"* ]]; then
    return 0
  else # if headless chrome fails to render any map nodes
    echo "Map not rendered, setting exit status to 125 (skip during bisect skip)."
    return 1
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
export -f __test_mapjs_renders
