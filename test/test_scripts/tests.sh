#!/usr/bin/env bash

# Functions beginning with __ are not considered part of a public API, and therefore updates may change them without warning.

# Ensure Dev server running for tests. Start early since it takes a little while to get going.
webpack_pack
__start_mapjs_webserver

# Have switched rendering to be second test.
# Before moving to first, need to fix race condition with web server
# Ensure server running before runnig first html test.
#   TODO: Would be better to store the time here and then pause the difference before running html tests.
# sleep 1.5
# Or would this work?
#   wait

echo 'Attempting to delete old test outputs.'

__clean_repo

# rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.yml"
# rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.mup"

# todo Delete old gdrive file
# 1uU7_yfAwMPV3a0lxpiXoVR-m0hbX2Pzs
# Though may not be consistently same name anyway, would need to create with fix name

COLOUR='true' # true
TESTNUM=1
FAILCOUNT=0 #count failed tests, also acts at return code at end; 0 = success

COL_PASS=""
COL_FAIL="<< "
COL_RESET=""

case "$TERM" in
dumb)
    COLOUR='false'
    echo "Colour not supported by terminal."
    ;;
*) ;;
esac

# Or try: if [ "$color_prompt" = yes ]; then
if [ $COLOUR = 'true' ]; then
    echo "Colour supported"
    COL_PASS='\033[0;32m' # Green
    COL_FAIL='\033[0;31m' # Red
    COL_RESET='\033[0m'   # No Color
fi

# This function is not considered part of a public API, and therefore updates may change them without warning.
__test() {
    PRE="Test $TESTNUM:"
    echo -en "$PRE "

    # Could return pass/fail instead: return $returnValue (or alternatively would returnVariable work?)
    if "$1" "$2" >>"$PATH_TEST_LOG"; then
        echo -e "${COL_PASS}Pass${COL_RESET}"
    else
        echo -e "$PRE ${COL_FAIL}Fail${COL_RESET}"
        FAILCOUNT=$((FAILCOUNT + 1))
    fi

    TESTNUM=$((TESTNUM + 1))
}

# todo turn these into an array
# array0=(one two three four five six)
# for i in "${array0[@]}"; do
#     echo "$i"
# done
# or
# for Variable in {1..3}
# do
#     echo "$Variable"
# done
# or could loop through files in a folder
# for test/output in $(ls)
# do
#     cat "$test/output"
# done

if [ "$1" != html ]; then
    __test a2m "$INPUT_FILE_YML"       #1
    __test a2m "$INPUT_FILE_YML_NOTES" #2
    __test m2a "$INPUT_FILE_JSON"      #3
    __test a2t "$INPUT_FILE_YML"       #4
    __test a2mu "$INPUT_FILE_YML"      #5
# __test a2jo "$INPUT_FILE_YML"
fi

# map renders
__test md2hf "$INPUT_FILE_MD0"                      #6
__test __test_mapjs_renders "$PATH_INPUT_FILE_HTML" #7
__test md2hf "$INPUT_FILE_MD"                       #8
__test md2hf "$INPUT_FILE_MD2"                      #9
__test md2hf "$INPUT_FILE_MD_META"                  #10
# To make browser test visible, add 'head' as first arg
__test testcafe_run "$PATH_REPLAY_SCRIPT_ADD_IDEA"         #11 add child button works
__test testcafe_run "$PATH_REPLAY_SCRIPT_NODE_CLICK"       #12 left click works
__test testcafe_run "$PATH_REPLAY_SCRIPT_BUTTON_UNDO_REDO" #13 undo/redo button works
__test testcafe_run "$PATH_REPLAY_SCRIPT_ADD_ROOT_PARENT"  #14

# These don't work
# __test testcafe_run "$PATH_REPLAY_SCRIPT_KEYS_UNDO_REDO"      #15 undo/redo keys fails in testcafe, first ctrl-z step didn't work.
# __test testcafe_run "$PATH_REPLAY_SCRIPT_BUTTON_ADD_LINK"     #16 add link works
# __test testcafe_run "$PATH_REPLAY_SCRIPT_EDIT_FIRST_CHILD"    #17 edit first child node
# __test testcafe_run "$PATH_REPLAY_SCRIPT_ADD_SUPPORTING"      #18 ERROR: Action "selector" argument error: missing ) after argument list
# __test testcafe_run "$PATH_REPLAY_SCRIPT_ADD_SUPPORTING_E2V3" #19
# __test testcafe_run "$PATH_REPLAY_SCRIPT_BUTTON_ZOOM"         #20
# __test testcafe_run "$PATH_REPLAY_SCRIPT_KEYS_ZOOM"           #21
# __test testcafe_run "$PATH_REPLAY_SCRIPT_DELETE_GRANDCHILD"   #22
# __test testcafe_run "$PATH_REPLAY_SCRIPT_EDIT_LINK"           #23

if [ "$1" != html ]; then
    __test md2pdf "$INPUT_FILE_MD0" #15
fi

echo "Testing finished, $FAILCOUNT tests failed."
echo "If first html test failed, check whether webserver was running."
echo "Test cafe log location: $PATH_TEST_LOG"

exit $FAILCOUNT
