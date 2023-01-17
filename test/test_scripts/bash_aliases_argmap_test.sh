#!/usr/bin/env bash

# For running casual tests and checks.
# These aliases are not considered part of a public API, and therefore updates may change them without warning.

echo "Running ${BASH_SOURCE[0]}"

# argmap test Aliases

# todo Delete old gdrive file
# 1uU7_yfAwMPV3a0lxpiXoVR-m0hbX2Pzs
# Though may not be consistently same name anyway, would need to create with fixed name
alias argmm='rm $INPUT_FILE_JSON; a2m $INPUT_FILE_YML'
alias argmy='rm $DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.yml; m2a $INPUT_FILE_JSON'
alias argmt='rm $DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.tex; a2t $INPUT_FILE_YML'
alias argmu='a2mu $INPUT_FILE_YML'
alias argmup='__chrome-attach https://drive.mindmup.com/map/1FY98eeanu9vAhIqBG1rDKFs3QyM1uQyY'

#TODO: need to delete previous file, best way? Separate output folder or just delete all .json in test/output folder?
alias argmo='rm $DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.mup; a2mo $INPUT_FILE_YML'
alias argmh0='rm $DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-0mapjs.html; rm $DIR_PUBLIC_OUTPUT/png/12ff0311ebc308e94fe0359b761fa405b605f126.png; md2hf $INPUT_FILE_MD0'
alias argmh='rm $DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs.html; rm $DIR_PUBLIC_OUTPUT/png/920713d1a74abe16c16b3fb103f893e64c5fb3ca.png; md2hf $INPUT_FILE_MD'
alias argmh2='rm $DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-2mapjs.html; md2hf $INPUT_FILE_MD2'
alias argmhmeta='rm $DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-meta-mapjs.html; md2hf $INPUT_FILE_MD_META'
alias argmp='rm $DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.pdf; md2pdf $INPUT_FILE_MD'
alias argmph='rm $DIR_PUBLIC_OUTPUT/example.pdf; rm $DIR_PUBLIC_OUTPUT/header.tex; $PATH_DIR_ARGMAP_LUA/argmap2tikz.lua -i > $DIR_PUBLIC_OUTPUT/header.tex; pandoc $INPUT_FILE_MD -o $DIR_PUBLIC_OUTPUT/example.pdf --lua-filter pandoc-argmap.lua --pdf-engine lualatex --include-in-header $DIR_PUBLIC_OUTPUT/header.tex --data-dir=$CONDA_PREFIX/share/pandoc; echo "Generated: $DIR_PUBLIC_OUTPUT/example.pdf"'
alias argmf='rm $DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs-fragment.html; md2htm $WORKSPACE/test/input/markdown/example1-clearly-false-white-swan-simplified-1mapjs.md'
alias argt='$WORKSPACE/test/test_scripts/tests.sh'
alias argth='$WORKSPACE/test/test_scripts/tests.sh html'

__init_tests() {
  COLOUR='true'
  TESTNUM=1
  FAILCOUNT=0 # count failed tests, also acts at return code at end; 0 = success

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
}

# This function is not considered part of a public API, and therefore updates may change them without warning.
__test() {
  PRE="Test $TESTNUM:"
  echo -en "$PRE "

  # Could return pass/fail instead: return $returnValue (or alternatively would returnVariable work?)
  if "$@" >>"$PATH_TEST_LOG"; then
    echo -e "${COL_PASS}Pass${COL_RESET}"
  else
    echo -e "$PRE ${COL_FAIL}Fail${COL_RESET}"
    FAILCOUNT=$((FAILCOUNT + 1))
  fi

  TESTNUM=$((TESTNUM + 1))
}

export -f __init_tests check_var_value __test test_getvar
