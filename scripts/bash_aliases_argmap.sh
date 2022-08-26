#!/usr/bin/env bash

# argmap functions

## Functions beginning with __ are for other scripts. They are not considered part of a public API, and therefore updates may change them without warning.

echo "Running ${BASH_SOURCE[0]}"

## browser functions

# TODO try shortcut to run test with chrome headless and check that it's correct: https://workflowy.com/#/8aac548986a4
#   Maybe review mapjs tests.

## version control functions

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
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.yml"
  # rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.mup"
  rm "$PATH_MJS_JSON/Example1_ClearlyFalse_WhiteSwan_simplified.json"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified.tex"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_0mapjs.pdf"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_0mapjs.html"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs.html"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_2mapjs.html"
  rm "$DIR_HTML_OUTPUT/Example1_ClearlyFalse_WhiteSwan_simplified_meta_mapjs.html"
  rm "$DIR_HTML_OUTPUT/png/f54eea6ed0c060c9d27e1fe3507bfdd75e3e60d4.png"
  # rm "$INPUT_FILE_JSON"
}

__save_env() {
  conda env export --from-history --name "$CONDA_ENV_ARGMAP" >"$ENV_FILE"
  # TODO: Prepare Environment YAML For Distribution
  # https://workflowy.com/#/b0011d3b3ba1
}

## argmap functions

# Convert to map.json, writes it to test/output/mapjs-json/
# lua argmap2mup test/input/Example1_ClearlyFalse_WhiteSwan_simplified.yml > test/output/mapjs-json/Example1_ClearlyFalse_WhiteSwan_simplified.json
# TODO add option for .mup vs .json output
a2m() {                                    # a2m test/input/Example1_ClearlyFalse_WhiteSwan_simplified.yml
  NAME=$(basename --suffix=".yml" "$1") && # && ensures error failure stops remaining commands.
    OUTPUT=${2:-$PATH_MJS_JSON/$NAME.json} &&
    argmap2mup "$1" >"$OUTPUT" &&
    echo "$OUTPUT" # Output path can be piped
}

# Convert to map.js and upload
a2mu() { # a2mu test/output/Example1_simple.yml
  NAME=$(basename --suffix=".yml" "$1") &&
    argmap2mup --upload --name "$NAME.mup" --folder 1cSnE4jv5f1InNVgYg354xRwVPY6CvD0x "$1" &&
    echo "Uploaded: $1 to GDrive."
}

# Convert map.js to argmap yaml format
# TODO add option for .mup vs .json output
m2a() { # m2a test/output/Example1_simple.mup
  NAME=$(basename --suffix=".json" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.yml}
  mup2argmap "$1" >"$OUTPUT" &&
    echo "$OUTPUT" # Output path can be piped
}

# Convert to tikz
a2t() { # a2t test/output/Example1_simple.yml
  NAME=$(basename --suffix=".yml" "$1") &&
    argmap2tikz "$1" >"${2:-$DIR_HTML_OUTPUT/$NAME.tex}" &&
    echo "${2:-$DIR_HTML_OUTPUT/$NAME.tex}"
}

# Convert markdown to full page html
md2hf() { # md2h test/input/example.md
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  # QUESTION: Is it worth putting some of these settings into a metadata or defaults file?
  # If so, how would I easily update it?
  # Useful? --metadata=curdir:X
  # css here overrides the template value, which may not be what I want. Not sure best way to handle.
  # https://workflowy.com/#/ee624e71f40c
  pandoc "$1" --template "$WORKSPACE/pandoc-templates/mapjs/mapjs-main-html5.html" --metadata=mapjs-output-js:"$FILE_MJS_JS" --metadata=css:"$MJS_CSS" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
}

# shellcheck disable=SC2120 # Disables lint error
j2hf() {             # j2hf test/output/mapjs-json/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs_argmap2.json
  INPUT=${1:-$(cat)} # If there is an argument, use it as input file, else use stdin (expecting piped input)
  NAME=$(basename --suffix=".json" "$INPUT")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}
  PATH_OUTPUT_JSON=$DIR_MJS_JSON/$NAME.json # Assumes file is in the JSON output folder
  echo "" | pandoc --template "$WORKSPACE/pandoc-templates/mapjs/mapjs-quick-json.html" --metadata=BLOCK_ID:"1" --metadata title="$NAME" --metadata=path-json-source:"$PATH_OUTPUT_JSON" --metadata=mapjs-output-js:"$FILE_MJS_JS" --metadata=css:"$MJS_CSS" -o "$OUTPUT" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
}

a2hf() { # a2hf test/input/Example1_ClearlyFalse_WhiteSwan_simplified.yml
  a2m "$1" | j2hf
}

# Convert markdown to html fragment
# TODO: lua filter should include main.js etc even for fragment
md2htm() { # md2htm test/input/example-updated.md
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.html}

  # TODO: Put this into new function?
  # Or use a defaults file:
  # https://workflowy.com/#/ee624e71f40c
  pandoc "$1" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.html"
}

# Convert markdown to pdf
md2pdf() { # md2pdf test/input/example.md
  NAME=$(basename --suffix=".md" "$1")
  OUTPUT=${2:-$DIR_HTML_OUTPUT/$NAME.pdf}
  pandoc "$1" -o "$OUTPUT" --lua-filter="$WORKSPACE/src/pandoc-argmap.lua" --pdf-engine lualatex --template "$WORKSPACE/examples/example-template.latex" --data-dir="$PANDOC_DATA_DIR" >/dev/null &&
    echo "$OUTPUT"
  open-server "$DIR_HTML_SERVER_OUTPUT/$NAME.pdf"
}

# Deprecated

## Deprecated, use a2m() for converting argmap to .mup/.json and use __build_mapjs to rebuild app
a2jo() { # m2a output/mapjs-json-input/Example1_simple.yml
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
