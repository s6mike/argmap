#!/usr/bin/env bash

# Script to run for each git bisect iteration (or use alias bru or bre):
# git bisect run ~/scripts/argmap_test_scripts/mapjs_bisect_testcafe.sh

# First time only (or use alias wss):
# npm exec webpack-dev-server

# Bisect Setup
# ------------

# QUESTION can I move these two commands outside of this script into calling function?
export PATH_REPLAY_SCRIPT=$DIR_PROJECTS/argmap/test/devtools-recordings/add_idea.json

source /home/s6mike/scripts/bash_aliases.sh # Functions to ensure clean build.

# Add Hotfixes
# ------------

# Want stash files to be absolute minimum to avoid merge conflicts
# This stops bisect if apply breaks (125 to skip commit and continue testing)
#  Alternative to stash apply: https://workflowy.com/#/c1fcaad78669

# Does package.json use 'webpack-dev-server': '^2.4.1'?
# Has start.js alert but changed to console error? Not essential
# stash@{0}: On (no branch): package.json version, start.js alert

# map-model.js _ fix

git stash apply || (
  echo "'git stash apply' failed, exit 255 (abort bisect)"
  exit 255
)

echo "'git stash apply' successful."

# Build
#------

# npm install
# wait
# npm exec webpack
# wait

# webpack_build
npm install --legacy-peer-deps

# webpack_server_start # Dev server should already be started
# wait

# "testc": "npm run test-cafe",
# "test-start": "npm run start && npm run test-cafe",
# "stop": "killall node",
# "start": "npm run pack && webpack-dev-server &",
# "test-cafe": "testcafe 'chrome:headless --no-default-browser-check' $DIR_PROJECTS/argmap/test/devtools-recordings/Add_supporting_group.json",
# "pack": "webpack",
#  "server": "webpack-dev-server"

# git add -u

# TODO: Ideally want to read node_count_before and pass it into the JSON script as a variable to compare it to.
#   See https://workflowy.com/#/33d0bdfaf875
# node_count_before = document.getElementsByClassName('mapjs-node').length

# Run Test
# --------

# Pre-test: Does page load?

# Check url:
# check_url '' || status=125

# if [ $status == 125 ]; then
#   echo "Page unavailable, setting exit status to 125"
# else

# Pre-test: Do any elements render?

# npm exec testcafe 'chrome:headless --no-default-browser-check' $DIR_PROJECTS/argmap/test/devtools-recordings/map_renders.json >>"../git-bisect-logs/$BISECT_START_TIMESTAMP-testcafe-output.txt"
# renders=$?

# if [ $renders != 0 ]; then

# echo a$("$HOME/scripts/argmap_test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")
RENDERS=$("$HOME/scripts/argmap_test_scripts/headless_chrome_repl_mapjs_is_rendered.exp")
# RENDERS text value is not normal: for some reason text coming after it gets moved to the start. Think it was trailing \r I added.
# TODO: test, then update comments, but leave trailing wildcard.
# e.g. echo "RENDERS: $RENDERS." = .ENDERS: true
# Using trailing wildcard match in case any newline characters accidentally captured, like I did before, so they don't breka match.
if [[ "$RENDERS" == "true"* ]]; then
  # Main test
  # Better to use exec so not dependent on package.json
  npm exec testcafe 'chrome:headless --no-default-browser-check' "$PATH_REPLAY_SCRIPT" >>"../git-bisect-logs/$BISECT_START_TIMESTAMP-testcafe-output.txt"
  status=$?
else # if headless chrome fails to render any map nodes
  status=125
  echo "Map not rendered, setting exit status to 125 (bisect skip)."
fi

# Included in test (expecting 14):
# node_count_after = document.getElementsByClassName('mapjs-node').length
# exit if node_count_after > node_count_before then 0 else 1

# Bisect Teardown
# ---------------

# node_stop
# This is necessary to allow checkout to work for next bisect step:
git reset --hard

# Return test result
echo "bisect exit status: $status"
exit "$status"

# After fix:
# ----------

# Review bisect log
# git bisect log >../git-bisect-logs/git_bisect_log_"$(basename --suffix=".json" "$PATH_REPLAY_SCRIPT")".txt

# Repeat bisect
# git bisect log >../git-bisect-logs/git_bisect_log_"$(basename --suffix=".json" "$PATH_REPLAY_SCRIPT")".txt
# Edit log, then:
# git bisect reset
# git bisect replay ../git-bisect-logs/git_bisect_log_"$(basename --suffix=".json" "$PATH_REPLAY_SCRIPT")".txt
# git bisect run ~/scripts/argmap_test_scripts/mapjs_bisect_testcafe.sh

# Get diff of staging area vs prev commit
# git add -u
# git stash -u -m "cumulative-fixes"
# git diff --cached >../mapjs_cumulative_fixes.diff
