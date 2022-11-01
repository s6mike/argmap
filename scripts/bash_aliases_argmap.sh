#!/usr/bin/env bash

echo "Running ${BASH_SOURCE[0]}"

# argmap aliases
alias odb='open-debug' # odb /home/s6mike/git_projects/argmap/mapjs/site/output/mapjs-json/example1-clearly-false-white-swan-simplified-1mapjs_argmap2.json

# argmap functions

## Functions beginning with __ are for other scripts. They are not considered part of a public API, and therefore updates may change them without warning.

## browser functions

# TODO: Use realpath to simplify relative path juggling
#   e.g. PATH_OUTPUT_JSON=/$(realpath --no-symlinks --relative-to=mapjs/site "$1")

# TODO try shortcut to run test with chrome headless and check that it's correct: https://workflowy.com/#/8aac548986a4
#   Maybe review mapjs tests.

## version control functions

# TODO: Use realpath to simplify relative path juggling
#   e.g. PATH_OUTPUT_JSON=/$(realpath --no-symlinks --relative-to=mapjs/site "$1")

# TODO: try chrome headless: https://workflowy.com/#/8aac548986a4
# TODO: user data dir doesn't seem to work, showing normal linux browser
# For opening html pages with debug port open
open-debug() { # odb /home/s6mike/git_projects/argmap/mapjs/site/input/html/example2-clearly-false-white-swan-v3.html
  INPUT_PATH="${1:-$DIR_HTML/$PATH_INPUT_FILE_HTML}"
  case $INPUT_PATH in
  /*)
    FULL_PATH=$INPUT_PATH
    ;;
  *)
    FULL_PATH=$WORKSPACE/$INPUT_PATH
    ;;
  esac
  # Substitutes mapjs/site for test so its using site folder, then removes leading part of path:
  SITE_PATH="${FULL_PATH/test/"mapjs/site"}"
  # echo "SITE_PATH: $SITE_PATH"
  PATH_PAGE=$(realpath --no-symlinks --relative-to="$PATH_MJS_HOME"/site "$SITE_PATH")
  google-chrome --remote-debugging-port="$PORT_DEBUG" --user-data-dir="$PATH_CHROME_PROFILE_DEBUG" --disable-extensions --hide-crash-restore-bubble --no-default-browser-check "http://localhost:$PORT_DEV_SERVER/$PATH_PAGE" 2>/dev/null &
  disown # stops browser blocking terminal and allows all tabs to open in single window.
}

# Checks `src/` for lua files with leftover test/debug code.
# Used by pre-commit hook
__check_repo() {
  grep -Frni "$WORKSPACE/src" -e 'logger:setLevel(logging.DEBUG)' -e 'require("lldebugger").start()'
}

# Used by pre-commit hook
__reset_repo() {
  echo 'Restoring output folder to match remote.'
  git checkout -- "$WORKSPACE/examples/"
  git checkout -- "$WORKSPACE/test/output/"
  git checkout -- "$DIR_HTML_OUTPUT"
}

__clean_repo() {
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified.yml"
  # rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified.mup"
  rm "$PATH_MJS_JSON/example1-clearly-false-white-swan-simplified.json"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified.tex"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified-0mapjs.pdf"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified-0mapjs.html"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified-1mapjs.html"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified-2mapjs.html"
  rm "$DIR_HTML_OUTPUT/example1-clearly-false-white-swan-simplified-meta-mapjs.html"
  rm "$DIR_HTML_OUTPUT/png/f54eea6ed0c060c9d27e1fe3507bfdd75e3e60d4.png"
  rm "$PATH_TEST_LOG"
  # rm "$INPUT_FILE_JSON"
}

__save_env() {
  conda env export --from-history --name "$CONDA_ENV_ARGMAP" >"$ENV_FILE"
  # TODO: Prepare Environment YAML For Distribution
  # https://workflowy.com/#/b0011d3b3ba1
}

## argmap functions

# Convert to map.json, writes it to test/output/mapjs-json/
# lua argmap2mup test/input/example1-clearly-false-white-swan-simplified.yml > test/output/mapjs-json/example1-clearly-false-white-swan-simplified.json
# TODO add option for .mup vs .json output
a2m() {                                    # a2m test/input/example1-clearly-false-white-swan-simplified.yml
  NAME=$(basename --suffix=".yml" "$1") && # && ensures error failure stops remaining commands.
    OUTPUT=${2:-$PATH_MJS_JSON/$NAME.json} &&
    mkdir --parent "$(dirname "$OUTPUT")" && # Ensures output folder exists
    argmap2mup "$1" >"$OUTPUT" &&
    echo "$OUTPUT" # Output path can be piped
}

# Convert to map.js and upload
a2mu() { # a2mu test/output/example1-simple.yml
  NAME=$(basename --suffix=".yml" "$1") &&
    argmap2mup --upload --name "$NAME.mup" --folder 1cSnE4jv5f1InNVgYg354xRwVPY6CvD0x "$1" &&
    echo "Uploaded: $NAME.mup to GDrive."
}

# Convert map.js to argmap yaml format
# TODO add option for .mup vs .json output
m2a() { # m2a test/output/example1-simple.mup
  NAME=$(basename --suffix=".json" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.yml}
  mkdir --parent "$(dirname "$OUTPUT")" # Ensures output folder exists
  mup2argmap "$1" >"$OUTPUT" &&
    echo "$OUTPUT" # Output path can be piped
}

# Convert to tikz
a2t() { # a2t test/output/example1-simple.yml
  NAME=$(basename --suffix=".yml" "$1") &&
    mkdir --parent "$(dirname "$OUTPUT")" && # Ensures output folder exists
    argmap2tikz "$1" >"${2:-$DIR_HTML_OUTPUT/$NAME.tex}" &&
    echo "${2:-$DIR_HTML_OUTPUT/$NAME.tex}"
}

# Convert markdown to full page html
mdhello() { # md2h test/input/example.md
  # TODO: Use realpath to simplify relative path juggling
  #   e.g. PATH_OUTPUT_JSON=/$(realpath --no-symlinks --relative-to=mapjs/site "$1")
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  mkdir --parent "$(dirname "$OUTPUT")" # Ensures output folder exists
  # QUESTION: Is it worth putting some of these settings into a metadata or defaults file?
  # If so, how would I easily update it?
  # Useful? --metadata=curdir:X
  # css here overrides the template value, which may not be what I want. Not sure best way to handle.
  # https://workflowy.com/#/ee624e71f40c
  pandoc "$1" --lua-filter="$WORKSPACE/src/pandoc-hello.lua" --template "$WORKSPACE/pandoc-templates/mapjs/mapjs-main-html5.html" --metadata=mapjs-output-js:"$FILE_MJS_JS" --metadata=css:"$MJS_CSS" -o "$OUTPUT" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  # QUESTION: Change to open-debug? Might want to make debug default, but with test option for normal.
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
  # TODO construct link from server details and output it?
}

# Convert markdown to full page html
md2hf() { # md2h test/input/example.md
  # TODO: Use realpath to simplify relative path juggling
  #   e.g. PATH_OUTPUT_JSON=/$(realpath --no-symlinks --relative-to=mapjs/site "$1")
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  mkdir --parent "$(dirname "$OUTPUT")" # Ensures output folder exists
  # QUESTION: Is it worth putting some of these settings into a metadata or defaults file?
  # If so, how would I easily update it?
  # Useful? --metadata=curdir:X
  # css here overrides the template value, which may not be what I want. Not sure best way to handle.
  # https://workflowy.com/#/ee624e71f40c
  pandoc "$1" --template "$WORKSPACE/pandoc-templates/mapjs/mapjs-main-html5.html" --metadata=mapjs-output-js:"$FILE_MJS_JS" --metadata=css:"$MJS_CSS" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  # QUESTION: Change to open-debug? Might want to make debug default, but with test option for normal.
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
  # TODO construct link from server details and output it?
}

# shellcheck disable=SC2120 # Disables lint error
j2hf() { # j2hf site/output/mapjs-json/example1-clearly-false-white-swan-simplified-1mapjs-argmap2.json
  # TODO If input defaults to cat, write to a file in input folder and then pass path onto pandoc.
  # INPUT=${1:-$(cat)} # If there is an argument, use it as input file, else use stdin (expecting piped input)
  INPUT="${1:-$INPUT_FILE_JSON}"
  # Substitutes mapjs/site for test so its using site folder, then removes leading part of path:
  SITE_PATH="${INPUT/test/"mapjs/site"}"
  # Removes either suffix:
  NAME=$(basename --suffix=".json" "$SITE_PATH")
  NAME=$(basename --suffix=".mup" "$NAME")
  HTML_OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  #  TODO: Check and copy to input folder?
  PATH_OUTPUT_JSON=/$(realpath --no-symlinks --relative-to=mapjs/site "$SITE_PATH")
  mkdir --parent "$(dirname "$HTML_OUTPUT")" # Ensures output folder exists
  # mkdir --parent "$(dirname "$PATH_OUTPUT_JSON")" # Ensures JSON output folder exists
  echo "" | pandoc --template "$WORKSPACE/pandoc-templates/mapjs/mapjs-quick-json.html" --metadata=BLOCK_ID:"1" --metadata title="$NAME" --metadata=path-json-source:"$PATH_OUTPUT_JSON" --metadata=mapjs-output-js:"$FILE_MJS_JS" --metadata=css:"$MJS_CSS" -o "$HTML_OUTPUT" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$HTML_OUTPUT"
  open-debug "$HTML_OUTPUT"
}

a2hf() { # a2hf test/input/example1-clearly-false-white-swan-simplified.yml
  a2m "$1" | j2hf
}

# Convert markdown to html fragment
# TODO: lua filter should include main.js etc even for fragment
md2htm() { # md2htm test/input/example-updated.md
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  mkdir --parent "$(dirname "$OUTPUT")" # Ensures output folder exists
  # TODO: Put this into new function?
  # Or use a defaults file:
  # https://workflowy.com/#/ee624e71f40c
  pandoc "$1" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-debug "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
}

# Convert markdown to pdf
md2pdf() { # md2pdf test/input/example.md
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.pdf}
  mkdir --parent "$(dirname "$OUTPUT")" # Ensures output folder exists
  pandoc "$1" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --pdf-engine lualatex --template "$WORKSPACE/examples/example-template.latex" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.pdf"
}

# Deprecated

## Deprecated, use a2m() for converting argmap to .mup/.json and use __build_mapjs to rebuild app
a2jo() { # m2a output/mapjs-json-input/example1-simple.yml
  NAME=$(basename --suffix=".yml" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.json}
  a2m "$1" "$OUTPUT"
}

## Deprecated, use a2jo instead.
a2mo() {
  NAME=$(basename --suffix=".yml" "$1") &&
    OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.json} &&
    a2m "$1" "$OUTPUT"
}

## Mark functions for export to use in other scripts:
export -f __reset_repo __clean_repo __check_repo __save_env
export -f a2m m2a a2t a2mu md2htm md2hf md2pdf j2hf a2hf
