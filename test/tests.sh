#!/usr/bin/env bash

# Functions beginning with __ are not considered part of a public API, and therefore updates may change them without warning.

echo 'Attempting to delete old test outputs.'

__clean_repo
rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.yml"
rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.mup"

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
    if "$1" "$2" >/dev/null; then
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
    __test a2m "$INPUT_FILE_YML"  #1
    __test m2a "$INPUT_FILE_JSON" #2
    __test a2t "$INPUT_FILE_YML"  #3
    __test a2mu "$INPUT_FILE_YML" #4
# __test a2jo "$INPUT_FILE_YML"   #5
fi

__test md2hf "$INPUT_FILE_MD0"     #6
__test md2hf "$INPUT_FILE_MD"      #7
__test md2hf "$INPUT_FILE_MD2"     #8
__test md2hf "$INPUT_FILE_MD_META" #9

if [ "$1" != html ]; then
    __test md2pdf "$INPUT_FILE_MD0" #10
fi

echo "Testing finished, $FAILCOUNT tests failed."

exit $FAILCOUNT
