#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# argmap aliases
alias odb='open_debug' # odb /home/s6mike/git_projects/argmap/mapjs/public/output/mapjs-json/example1-clearly-false-white-swan-simplified-1mapjs_argmap2.json
alias j2hfa='2hf test/input/mapjs-json/example1-clearly-false-white-swan-simplified.json example1-clearly-false-white-swan-simplified --metadata=argmap-input:true'

# argmap functions

## Functions beginning with __ are for other scripts. They are not considered part of a public API, and therefore updates may change them without warning.

## browser functions

# TODO: Use __get_site_path() to simplify relative path juggling

# TODO: try shortcut to run test with chrome headless and check that it's correct: https://workflowy.com/#/8aac548986a4
#   QUESTION: review mapjs tests?

# TEST: test_get_site_path()
__get_site_path() {
  input_path="$1"
  case $input_path in
  /*)
    full_path=$input_path
    ;;
  *)
    full_path=$(getvar WORKSPACE)/$input_path
    ;;
  esac
  # Substitutes mapjs/public for test so it's using public folder, then removes leading part of path so its relative to public/:
  site_path="${full_path/test/$(getvar DIR_MJS)/$(getvar DIR_PUBLIC)}"
  output_path=$(realpath --no-symlinks --relative-to="$(getvar PATH_DIR_PUBLIC)" "$site_path")
  echo "$output_path"
}

# PATH_INPUT_FILE_HTML=$(realpath --no-symlinks --relative-to="$(getvar PATH_DIR_PUBLIC)" "$(getvar PATH_DIR_PUBLIC)/input/example1-clearly-false-white-swan-simplified.html")
# export PATH_INPUT_FILE_HTML
# PATH_OUTPUT_FILE_HTML=$(realpath --no-symlinks --relative-to="$(getvar PATH_DIR_PUBLIC)" "$(getvar PATH_DIR_PUBLIC)/output/html/example1-clearly-false-white-swan-simplified.html")
# export PATH_OUTPUT_FILE_HTML

# For opening html pages with debug port open
open_debug() { # odb /home/s6mike/git_projects/argmap/mapjs/public/output/html/example2-clearly-false-white-swan-v3.html
  # TODO: try chrome headless: https://workflowy.com/#/8aac548986a4
  # TODO: user data dir doesn't seem to work, showing normal linux browser
  webpack_server_start
  input_path="${1:-$(getvar DIR_HTML)/$(getvar PATH_OUTPUT_FILE_HTML)}"
  site_path=$(__get_site_path "$input_path")
  if [ "$site_path" != "" ]; then
    google-chrome --remote-debugging-port="$(getvar PORT_DEBUG)" --user-data-dir="$(getvar PATH_CHROME_PROFILE_DEBUG)" --disable-extensions --hide-crash-restore-bubble --no-default-browser-check "http://localhost:$(getvar PORT_DEV_SERVER)/$site_path" 2>/dev/null &
    disown # stops browser blocking terminal and allows all tabs to open in single window.
  fi
}

## version control functions

__update_repo() { # Running at end of test script
  echo "Updating repo..."
  # Update doc examples
  mv "$(2hf -p "$(getvar WORKSPACE)"/test/input/markdown/example-updated.md)" "$(getvar WORKSPACE)/docs/example-updated.html"
  mv "$(2hf -p "$(getvar WORKSPACE)"/test/input/mapjs-json/legacy-mapjs-example-map.json)" "$(getvar WORKSPACE)/mapjs/docs/legacy-mapjs-example-map.html"
  __save_env
  # __reset_repo  # Decided not to delete script output in case there are clues
  # __clean_repo # Decided not to delete script output in case there are clues
  __check_lua_debug
  __check_js_debug
  __check_npm_updates
}

__find_rockspec() {
  find "$WORKSPACE" -type f -name "argmap-*.rockspec"
}

# Checks `src/lua` for lua files with leftover debug code.
# Used by pre-commit hook
__check_lua_debug() {
  printf "\nChecking lua files for uncommented DEBUG mode directives. Expecting 1 only:\n"
  # 1st grep: Recursive search through directory, exclude lines starting with comments, show line numbers. Need to this filter first - because second grep will have line numbers etc to deal with.
  # 2nd grep: Fixed text, case insensitive
  grep -rnv '^\s*--' "$PATH_DIR_ARGMAP_LUA" | grep -Fie 'logger:setLevel(logging.DEBUG)' -e 'require("lldebugger").start()'
  echo "-------------"
}

# Checks `mapjs/src` for lua files with uncommented debug code.
# Used by __update_repo() (called from test script) and pre-commit hook (duplication)
__check_js_debug() {
  printf "\nChecking js files for uncommented console.debug commands. Expecting 0.\n"
  # 1st grep: Recursive search through directory, exclude lines starting with comments, show line numbers. Need to this filter first - because second grep will have line numbers etc to deal with.
  # 2nd grep: Fixed text, case insensitive
  grep -rnv '^\s*//' "$PATH_DIR_MJS_SRC_JS" | grep -Fie 'console.debug'
  echo "-------------"
}

# Used by pre-commit hook
__reset_repo() {
  echo 'Restoring output folder to match remote.'
  git checkout -- "$WORKSPACE/examples/"
  git checkout -- "$WORKSPACE/test/output/"
  git checkout -- "$DIR_PUBLIC_OUTPUT"
}

__clean_repo() {
  rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.yml"
  # rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.mup"
  rm "$PATH_DIR_PUBLIC_MJS_JSON/example1-clearly-false-white-swan-simplified.json"
  rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified.tex"
  rm "$DIR_PUBLIC_OUTPUT/example1-clearly-false-white-swan-simplified-0mapjs.pdf"
  rm "$DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs-fragment.html"
  rm "$DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-0mapjs.html"
  rm "$DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-1mapjs.html"
  rm "$DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-2mapjs.html"
  rm "$DIR_PUBLIC_OUTPUT/html/example1-clearly-false-white-swan-simplified-meta-mapjs.html"
  rm "$DIR_PUBLIC_OUTPUT/png/f54eea6ed0c060c9d27e1fe3507bfdd75e3e60d4.png"
  rm "$PATH_TEST_LOG"
  # rm "$INPUT_FILE_JSON"
}

__save_env() {
  conda env export --from-history --name "$CONDA_ENV_ARGMAP" >"$PATH_FILE_ENV_CONDA"
  # TODO: Prepare Environment YAML For Distribution
  # https://workflowy.com/#/b0011d3b3ba1
}

## argmap functions

# Convert to map.json, writes it to test/output/mapjs-json/
# lua argmap2mup test/input/example1-clearly-false-white-swan-simplified.yml > test/output/mapjs-json/example1-clearly-false-white-swan-simplified.json
# TODO add option for .mup vs .json output
a2m() {                                    # a2m test/input/example1-clearly-false-white-swan-simplified.yml (output path)
  name=$(basename --suffix=".yml" "$1") && # && ensures error failure stops remaining commands.
    output=${2:-$PATH_DIR_PUBLIC_MJS_JSON/$name.json} &&
    mkdir --parent "$(dirname "$output")" && # Ensures output folder exists
    lua "$PATH_DIR_ARGMAP_LUA/argmap2mup.lua" "$1" >"$output" &&
    echo "$output" "${@:2}" # Output path can be piped, along with any extra arguments
}

# Convert to map.js and upload
a2mu() { # a2mu test/output/example1-simple.yml
  name=$(basename --suffix=".yml" "$1") &&
    lua "$PATH_DIR_ARGMAP_LUA/argmap2mup.lua" --upload --name "$name.mup" --folder 1cSnE4jv5f1InNVgYg354xRwVPY6CvD0x "$1" &&
    echo "Uploaded: $name.mup to GDrive."
}

# Convert map.js to argmap yaml format
# TODO add option for .mup vs .json output
m2a() { # m2a test/output/example1-simple.mup (output path)
  name=$(basename --suffix=".json" "$1")
  output=${2:-$DIR_PUBLIC_OUTPUT/$name.yml}
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists
  lua "$PATH_DIR_ARGMAP_LUA/mup2argmap.lua" "$1" >"$output" &&
    echo "$output" # Output path can be piped
}

# Convert to tikz
a2t() { # a2t test/output/example1-simple.yml (output path)
  name=$(basename --suffix=".yml" "$1") &&
    mkdir --parent "$(dirname "$DIR_PUBLIC_OUTPUT")" && # Ensures output folder exists
    lua "$PATH_DIR_ARGMAP_LUA/argmap2tikz.lua" "$1" >"${2:-$DIR_PUBLIC_OUTPUT/$name.tex}" &&
    echo "${2:-$DIR_PUBLIC_OUTPUT/$name.tex}"
}

pandoc_argmap() { # pandoc_argmap input output template extra_variables
  input=${1:-""}
  output=${2:-$(getvar DIR_PUBLIC_OUTPUT)/html/pandoc_argmap-test.html}
  template=${3:-$(getvar FILE_TEMPLATE_HTML_ARGMAP_MAIN)}
  # TODO: Could replace this with pandoc_defaults_argmap.yml file, might be easier to selectively override. Should be able to interpolate path variables so it should fit in with yaml config approach.
  #   Plus could set up to override default defaults file with variations, which should make various combinations more portable
  pandoc "$input" -o "$output" --template="$template" "${@:4}" --from=markdown --metadata-file="$(getvar PATH_FILE_CONFIG_ARGMAP)" --metadata-file="$(getvar PATH_FILE_CONFIG_MJS)" --lua-filter="$(getvar PATH_DIR_ARGMAP_LUA)"/pandoc-argmap.lua --data-dir="$(getvar PANDOC_DATA_DIR)" >/dev/null
}

# Creates full page html intelligently based on input type.
#   Accepts: m, argmap, or json
#  TODO: Create md2x() which gives choice of output - html, fragment, pdf, native format etc
2hf() { # 2hf test/input/example.md (output filename) (optional pandoc arguments)
  default_template=""

  # doesn't open browser if -p used for Pipe mode
  OPTIND=1
  while getopts ":qp" option; do # Leading ':' in ":p" removes error message if no recognised options
    case $option in
    q) # quiet mode - doesn't print output path at end
      local quiet=true
      ;;
    p) # pipe mode - doesn't open browser, so only side effect is outputting filename, so can be piped to next command.
      local pipe=true
      ;;
    *) ;;
    esac
  done

  shift "$((OPTIND - 1))"

  input="${1:-$(getvar INPUT_FILE_MD2)}"
  output_name=$(basename "$input")
  ext=${output_name#*.}

  # Prev way:
  # name=$(basename --suffix=".$ext" "$input")
  name=${output_name%%.*}

  # echo "Input: $ext"
  case $ext in
  yml) # Converts argmap yaml into mindmup json then runs this command again on the output.
    # QUESTION: Is there a way I can pass data straight into json/mup step instead?
    2hf "$(a2m "$input")"
    return 0
    ;;
  json | mup) # Injects mindmup json into template
    # TODO If input defaults to cat, write to a file in input folder and then pass path onto pandoc.
    # input=${1:-$(cat)} # If there is an argument, use it as input file, else use stdin (expecting piped input)

    #  TODO: Check and copy to input folder?
    path_output_json=/$(__get_site_path "$input")
    input=/dev/null # JSON input feeds into template not body
    args="--metadata=quick-container:true --metadata=MAP_INSTANCE_ID:1 --metadata title=$name --metadata=path-json-source:$path_output_json"
    ;;
  md | *) # markdown is default option
    args=""
    ;;
  esac

  # TODO should check whether supplied output has extension already and then act accordingly
  #   Either strip it or choose output format based on ext

  # Substitutes mapjs/public for test so its using public folder, then removes leading part of path:
  #   TODO ideally would be more flexible with output location e.g. default to standard location but pick either filename or whole directory
  output=$(getvar DIR_PUBLIC_OUTPUT)/html/${2:-$name}.html
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists

  set -f # I don't want globbing, but I don't want to quote it because I do want word splitting
  # shellcheck disable=SC2086
  pandoc_argmap "$input" "$output" "$default_template" $args "${@:3}"
  set +f

  if [ "$pipe" != true ]; then
    open_debug "$output"
  fi
  if [ "$quiet" != true ]; then
    echo "$output"
  fi
}

# Convert markdown to pdf
md2pdf() { # md2pdf test/input/example.md (output filename) (optional pandoc arguments)
  name=$(basename --suffix=".md" "$1")
  output=$DIR_PUBLIC_OUTPUT/${2:-$name}.pdf
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists
  # Using "${@:3}" to allow 3rd argument onwards to be passed directly to pandoc.
  # QUESTION: Update to use pandoc_argmap?
  pandoc "$1" -o "$output" "${@:3}" --metadata-file="$PATH_FILE_MJS_CONFIG" --lua-filter="$PATH_DIR_ARGMAP_LUA/pandoc-argmap.lua" --pdf-engine lualatex --template="$WORKSPACE/examples/example-template.latex" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$output"
  open_debug "$output"
  # open-server "$DIR_HTML_SERVER_OUTPUT/$name.pdf"
}

# Convert markdown to native pandoc output
md2np() {
  input="${1:-$INPUT_FILE_MD2}"
  name=$(basename --suffix=".md" "$input")
  output=$DIR_PUBLIC_OUTPUT/html/${2:-$name}.ast
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists
  # QUESTION: Update to use pandoc_argmap?
  pandoc "$input" --to=native --metadata-file="$PATH_FILE_MJS_CONFIG" --template "$FILE_TEMPLATE_HTML_ARGMAP_MAIN" --metadata=css:"$MJS_CSS" --metadata=toolbar_main:toolbar-mapjs-main -o "$output" --lua-filter="$PATH_DIR_ARGMAP_LUA/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null
  code "$output"
}

# Mark functions for export to use in other scripts:
export -f __reset_repo __clean_repo __check_lua_debug __check_js_debug __save_env __update_repo __find_rockspec
export -f __get_site_path a2m m2a a2t a2mu pandoc_argmap 2hf md2pdf md2np

# DEPRECATED

#   TODO: Delete
get-site-path() {
  __get_site_path
}

__get-site-path() {
  __get_site_path
}

# DEPRECATED: Simpler to do as one liner
__gen_doc_map() {                                                             # Generates page for README.md example link destination
  path_output=$(md2hf -p "$WORKSPACE/test/input/markdown/example-updated.md") # -p activates pipe mode
  mv "$path_output" "$WORKSPACE/docs/"
}

# Convert markdown to html fragment - doesn't currently produce a fragment so DEPRECATED
#   Currently using include after body, which works fine, but uses default template so it's no longer a fragment
#   Looks like best way to generate a working html fragment probably to use lua filter to add the JS and CSS to the output html. This would also make mapjs more self contained - wouldn't add extra js/css to page if no container.
md2htm() { # md2htm test/input/markdown/example-updated.md (output filename) (optional pandoc arguments) # DEPRECATED AND RESERVED
  input="${1:-$INPUT_FILE_MD}"
  name=$(basename --suffix=".md" "$input")-fragment
  output=$DIR_PUBLIC_OUTPUT/html/${2:-$name}.html
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists
  # TODO: Would call pandoc-argument, but it was breaking, and this function is not really very useful anyway, so not bothering.
  # Using "${@:3}" to allow 3rd argument onwards to be passed directly to pandoc.
  pandoc "$input" -o "$output" "${@:3}" --metadata-file="$PATH_FILE_MJS_CONFIG" --include-after-body="$PATH_DIR_INCLUDES/webpack-dist-tags.html" --metadata=css:"$MJS_CSS" --lua-filter="$PATH_DIR_ARGMAP_LUA/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$output"
  open_debug "$output"
}

# DEPRECATED - use 2hf
# Convert markdown to full page html
# IDEA: Could combine md2htm by checking for an argument like --fragment and witholding template argument etc
#   Would need to use getopts and then pop the --fragment so that the number of other arguments are not affected
# TODO ideally would be more flexible with output location e.g. default to standard location but pick either filename or whole directory
md2hf() { # md2h test/input/example.md (output filename) (optional pandoc arguments)
  # doesn't open browser if -p used for Pipe mode
  OPTIND=1
  while getopts ":p" option; do # Leading ':' in ":p" removes error message if no recognised options
    case $option in
    p) # pipe mode - passed on filename instead of opening browser
      local pipe=true
      ;;
    *) ;;
    esac
  done

  shift "$((OPTIND - 1))"
  input="${1:-$(getvar INPUT_FILE_MD2)}"
  name=$(basename --suffix=".md" "$input")
  output=$(getvar DIR_PUBLIC_OUTPUT)/html/${2:-$name}.html
  mkdir --parent "$(dirname "$output")" # Ensures output folder exists

  # QUESTION: Is it worth putting some of these settings into a defaults file?
  # Useful? --metadata=curdir:X
  # css here overrides the template value, which may not be what I want. Not sure best way to handle.
  # https://workflowy.com/#/ee624e71f40c
  # Using "${@:3}" to allow 3rd argument onwards to be passed directly to pandoc.
  pandoc_argmap "$input" "$output" "" "${@:3}"

  if [ "$pipe" == true ]; then
    return 0
  fi

  # QUESTION: Might want to make debug default, but with test option for normal?
  #  open-server "$DIR_HTML_SERVER_OUTPUT/html/$name.html"
  # TODO construct link from server details and output it?
  open_debug "$output"
}

# DEPRECATED - use 2hf
# j2hf public/output/mapjs-json/example1-clearly-false-white-swan-simplified-1mapjs-argmap2.json (output filename) (optional pandoc arguments)
# shellcheck disable=SC2120 # Disables lint error from a2hf() passing to j2hf
j2hf() { # j2hfa Default output with argmap input activated
  # TODO If input defaults to cat, write to a file in input folder and then pass path onto pandoc.
  # input=${1:-$(cat)} # If there is an argument, use it as input file, else use stdin (expecting piped input)
  input="${1:-$(getvar INPUT_FILE_JSON)}"
  # Substitutes mapjs/public for test so its using public folder, then removes leading part of path:

  # Removes either suffix:
  name=$(basename --suffix=".json" "$input")
  name=$(basename --suffix=".mup" "$name")
  html_output=$(getvar DIR_PUBLIC_OUTPUT)/html/${2:-$name}.html
  mkdir --parent "$(dirname "$html_output")" # Ensures output folder exists

  #  TODO: Check and copy to input folder?
  path_output_json=/$(__get_site_path "$input")
  # mkdir --parent "$(dirname "$path_output_json")" # Ensures JSON output folder exists
  # Using "${@:3}" to allow 3rd argument onwards to be passed directly to pandoc.
  pandoc_argmap /dev/null "$html_output" "" "${@:3}" --metadata=quick-container:true --metadata=MAP_INSTANCE_ID:"1" --metadata title="$name" --metadata=path-json-source:"$path_output_json"
  open_debug "$html_output"
}

# DEPRECATED - use 2hf
a2hf() { # a2hf test/input/example1-clearly-false-white-swan-simplified.yml
  a2m "$1" | j2hf
}

export -f get-site-path __get-site-path md2htm
export -f md2hf j2hf a2hf
