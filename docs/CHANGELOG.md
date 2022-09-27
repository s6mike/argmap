# Argmap Project Change Log

## TODO

- Start to use - not _ in filenames. Change auto generation e.g. output folder since web stuff is better with -.
- Move `mapjs/site/mapjs-default-styles.css` to `mapjs/site/css`?
- [README.md](../README.md):
  - Add note about linking/using templates (html and latex) with pandoc.
- Add references to argmap specs?

## argmap 4.7.22

- `mapjs/src/core/content/content.js`: Fix bug causing error when adding node's first child.
  - This is because this code used to add a new child node `parentIdea.ideas[rank] = subIdea` needs to have rank 0 with new arrays, but was being given rank 0, corrupting array structure.
  - This code is used instead of push because it needs to work with both arrays and associative arrays.
- Add regression test:
  - `test/devtools-recordings/argmap-edit-first-child.json`: Add devtools recording.
  - `mapjs/scripts/mapjs.env`: Add path variable to recording.
  - `test/test_scripts/tests.sh`: Add regression test to call recording.
- [CHANGELOG-mapjs.md](../mapjs/docs/CHANGELOG-mapjs.md): Update with latest mapjs fix.

## argmap 4.7.21

- `scripts/bash_aliases_mapjs.sh`: Fix `__run_mapjs_legacy` to open chrome using debug profile (no chrome extensions).

## argmap 4.7.20

- Rename vscode debug attach profile for clarity.

## argmap 4.7.19

- Add mapjs edit link style fix from v3.3.21:
  - Fix `src/browser/link-edit-widget.js` so that widget correctly shows when links are dashed, and can be changed to solid lines again, by using line style val, rather than text.

## argmap 4.7.18

- Add two more TestCafe regression tests:
  - Click undo/redo buttons
  - Add link (though commenting out since it fails on git pre-commit hook)

## argmap 4.7.17

- Fix control widget css:
  - widget class and ids had been updated updated in template but not in `pandoc-templates/mapjs/mapjs-inline-styles.css` - now uses correct class.
  - Update min-height to 64 px, so that edit link widget appearing won't normally change height of canvas.
    - However, making window narrower can still create this side effect. Issue s6mike/mapjs#2.

## argmap 4.7.16

- Fix broken html generation:
  - `mapjs/scripts/mapjs.env` not being sourced:
    - Uncomment source command in `scripts/argmap_init_script.sh`
  - `png` and `mapjs-json` folders missing from `test/output`:
    - Create them in `scripts/install.sh`
    - Add comment todo to fix this in `pandoc-argmap.lua`

## argmap 4.7.15

- Add mapjs fixes from mapjs v3.3.11 to 3.3.20:
  - Enable cut/copy/paste.
  - Add missing keyboard shortcuts (hotkeyEventHandlers) for zoom in/out/reset, undo/redo, cut/copy/paste
  - Fix Add link button
  - Fix Edit Link Menu/Widget, including error messages when no link selected.
  - [mapjs/README.md](../mapjs/README.md): Add table listing keyboard shortcuts.
  - `mapjs/scripts/mapjs.env`: Update various environment variables.
  - Add jasmine test outputs to `mapjs/docs/` folder.
  - Update [CHANGELOG-mapjs.md](../mapjs/docs/CHANGELOG-mapjs.md).

## argmap 4.7.14

- Add `/test/devtools-recordings/mapjs-mouse-past-linkEditWidget-after-link-click.json` for new bisect test.

## argmap 4.7.13

- `scripts/install.sh`: Add TestCafe global install to simplify git bisect.

## argmap 4.7.12

- `test/test_scripts/mapjs_bisect_testcafe.sh`: Update teardown to remove untracked files, after this broke the bisect.

## argmap 4.7.11

- Add `/test/devtools-recordings/mapjs-button-add-link.json` for new bisect test.

## argmap 4.7.10

- Add `/test/devtools-recordings/mapjs-button-editlink-menu-error.json` for new bisect test.
- Update `/test/scripts/mapjs_bisect_testcafe.sh` to make apply patch step and browser sanity check optional.
- Update `/scripts/bash_aliases_mapjs.sh` and `/test/scripts/mapjs_bisect_testcafe.sh` to reflect mapjs bisect env variables and files being moved to external folder.

## argmap 4.7.9

- [README.md](../README.md): Fix broken internal links.

## argmap 4.7.8

- Add `test/devtools-recordings/mapjs-button-undo-redo.json` and `test/devtools-recordings/mapjs-keys-undo-redo.json` for new bisect tests.
- `scripts/bash_aliases_mapjs.sh`: Add function and alias to generate diff file for bisect.
- `test/test_scripts/mapjs_bisect_testcafe.sh`:
  - Update default diff file path.
  - Add rebuild step to stop server, reinstall and start server, and flag to skip this step.

## argmap 4.7.7

- Add `test/devtools-recordings/argmap-undo-redo.json` to test undo and redo buttons.
- Add above recording path to `mapjs.env` variable.

## argmap 4.7.6

- Update some log file folder locations.

## argmap 4.7.5

- Add mapjs fix from mapjs v3.3.9:
  - `src/core/map-model.js`: Fix left click on node to select (introduced in commit 'moved addLinkMode out of mapModel' 354071624edb6c257441fcdfcb3f11ab92ad395e).
  - Relevant function `clickNode` triggered by `mouseup`: `button` value wasn't used, so test `which` value instead.
- Add devtools recording and regression test for left click node select issue.
- `README.md`: Update mapjs install instructions.

## argmap 4.7.4

- Update test and automation files to work better with legacy mapjs repo:
  - Add `test/devtools-recordings/mapjs-node-click.json` to test left mouse click to select node.
  - `mapjs/scripts/mapjs.env`: Add variable for above script path, plus one for patch file (applied by bisect script as hotfix, rather than stash).
  - `test/test_scripts/mapjs_bisect_testcafe.sh`:
    - Make more reliable.
    - Add flags to simplify testing.
    - Apply patch rather than stash.
    - Add more messages for feedback.
  - `scripts/bash_aliases_mapjs.sh`: Minor changes so legacy mapjs can use aliases more easily.
  - `mapjs/.vscode/settings.json`: Add `scripts/bash_aliases_mapjs.sh` as terminal init file.
  
## argmap 4.7.3

- `test/test_scripts/mapjs_bisect_testcafe.sh`:
  - Check whether replay script chosen.
  - Show feedback messages in console.
  - Add test mode so git commands and install can be disabled. This stops changes being reset, and also speeds up testing.
  - Fix boolean logic checks.

## argmap 4.7.2

- Add bash debug profile to launch.json

## argmap 4.7.1

- Add browser test for adding child node:
  - `scripts/bash_aliases_mapjs.sh`: Add `testcafe_run()`.
  - Re-arrange `test/devtools-recordings`.
  - Add new devtool recording to test 'add child' on argmapjs example 1.1
  - Update env variables for TestCafe defaults.

## argmap 4.7.0

- Start adding browser tests:
  - Add symbolic link so input files accessible to dev server.
  - `test/scripts/tests.sh`:
    - Put TestCafe script's expect call into function so also callable from `test/scripts/tests.sh`.
  - Add alias for html page path for testing.

## argmap 4.6.4

- Rationalise various aliases and functions in argmap scripts and elsewhere.
  - Create `scripts/argmap.env` to store env variables instead of `scripts/init_script.sh`.
  - Separate mapjs related matter for easier sharing and re-use:
    - aliases and function into `scripts/bash_aliases_mapjs.sh`
    - env variables into existing `mapjs/scripts/mapjs.env`
- `scripts/bash_aliases_mapjs.sh`: Fix incorrect path in `__reset_repo()`.

## argmap 4.6.3

- `scripts/bash_aliases_argmap.sh`:
  - Update build script to install too.
  - Consolidate aliases at file start.

## argmap 4.6.2

- Add mapjs bugfixes (mapjs v3.3.6):
  - Fix add parent reason issue:
    - `test/start.js`: Errors sent to console.error, rather than alert which was incredibly annoying!
  - Fix toolbar buttons by restoring `src/browser/map-toolbar-widget` related code which was removed in commit 'initial jquery 3 migration' (`b2768ac`).
  - `src/core/content/content.js`: Fix reject call syntax which caused unrecognised function '_' error.
  - Change console.log to console.error for catching JSON load errors.
- `mapjs/package.json`: Downgrade version requirements back down again, will update versions once more mapjs bugs fixed.

## argmap 4.6.1

- Move remaining test scripts from `test/` to `test/test_scripts/`.
  - Update rockspec, scripts and docs with new paths.

## argmap 4.6.0

- `scripts/`:
  - Add git bisect run scripts for finding bugs in mapjs commit history.
  - Add devtools recording for checking mapjs page has rendered.
  - Add `test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp`:
    - ['expect' script](https://linux.die.net/man/1/expect) to use chrome headless REPL to check mapjs page has rendered.
      - Update `environment.yml`: install 'expect' as a development dependency.
  - `scripts/bash_aliases_argmap.sh`: Add `__run_mapjs_legacy()` for running legacy mapjs project (separate repo).

## argmap 4.5.1

- `mapjs/package.json`: Ensure webpack always applied before server start.
- `mapjs/src/start.js`: Change onerror from alert box to console.error
- Add devtools-recordings: for clicking all buttons for regression testing etc

## argmap 4.5.0

- Use webpack dev server for testing:
  - Update code and variables to write to correct folder.
  - `src/pandoc-argmap.lua`: Update `argmap2image()` to write png in correct folder.
    - `scripts/bash_aliases_argmap.sh`:
      - No longer need to move png after writing them.
      - Open server pages in ChromeOS native browser instead of Linux's installed chrome.
      - Add functions and aliases to start and stop web server.
      - Update functions to open dev server pages instead of local filesystem.
      - Update chrome attach aliases.
      - Minor function refinements.
  - `test/tests.sh`: Restart server before tests, plus minor fixes.
- Add `test/devtools-recordings` with recordings for testing mapjs nodes.
- `package.json`:
  - Add TestCafe module for automated testing using chrome devtools recordings.
  - Add alias script keys to align with npm lifecycle as described in: <https://docs.npmjs.com/cli/v8/using-npm/scripts>
- `scripts/argmap_init_script.sh`: Use $HOME env variable for portability.
- Add `mapjs/site/index.html` (symbolic link) to repo since missing.
  - Update `.gitignore`.
- Set up debug attach to avoid clashes with other vscode instances:
  - `.vscode/launch.json`: Change debugging port to 9221.
  - `scripts/bash_aliases_argmap.sh`:
    - Change debugging port to 9221
    - Set up separate chrome profile in temp folder and use to keep debugging port separate.

## argmap 4.4.1

- `src/core/content/content.js`: Fix sameSideSiblingRanks()

## argmap 4.4.0

- `mapjs/package.json`: Add alias script `build` to call webpack for simplicity, deprecate pack-js.
  - `scripts/bash_aliases_argmap.sh`: Update `__build_mapjs()` to use alias.

## argmap 4.3.2

- `scripts/install.sh`: Fix error with running conda install introduced v4.2.8
- `mapjs/docs/CHANGELOG-mapjs.md`: Document recent mapjs commits to mapjs repo.
- `.gitignore`: Remove mapjs package-lock.json since this should be in version control.

## argmap 4.3.1

- `pandoc-templates/mapjs/mapjs-inline-styles.css`: Fix css so mapjs displays container better.
- Add debug profile: `Attach to browser`.
- `scripts/bash_aliases_argmap.sh`: Add `__chrome-attach()` to open browser with debug ports.
- `test/bash_aliases_argmap_test.sh`: Add some aliases for debugging and testing scenarios.
- `.gitignore`: Add `remote-debug-profile`.
- `mapjs/src/start.js`: Use CommonJS instead of jQuery for some selectors etc.

## argmap 4.3.0

- `scripts/bash_aliases_argmap.sh`:
  - Delete `mapjs/site/js` before building.
  - Update functions generating files to echo the file path and nothing else, so file output can be used in pipe or by calling function with $().
  - Update `a2m()` to output `.json` and write it to JSON output folder.
    - Update `m2a()` to read `.json` files too.
    - Change test mup input file to `.json` input.
  - Add `j2hf()` for creating simple html page from `.json` input file.
  - Add `a2hf()` for creating simple html page from `.yml` input file.
- `pandoc-templates/mapjs`:
  - Add `mapjs-quick-json` template for simply showing mapjs, primarily for new `j2hf()` function.
  - Add template variables to partial templates, including JSON input file.
  - Update `src/pandoc-argmap.lua` to substitute template variable.
  - Add draft markdown file: `test/input/general_mapjs_viewer.md` for alternative solution to showing json easily.
  - Fix out of date debug profile parameters in `.vscode/launch.json`.

## argmap 4.2.12

- mapjs docs:
  - `LICENSE`: Add mapjs creator copyright.
  - Moved some docs from `mapjs/` to `mapjs/docs`.

## argmap 4.2.11

- `mapjs/test/`:
  - Move website dependencies to `site/`:
    - Move `/mapjs-default-styles.css`
      - `mapjs/scripts/mapjs.env`: Update env variable for css location.
    - Move all svg files to `site/svg/`.
  - Move js source files to `src/`:
    - Move `theme.js` and `themes/`.
      - `mapjs/src/start.js`: Update reference to `theme.js`.
  - `mapjs/webpack.config.js`: Create bundle.js in `site/js/` instead.
- Delete `mapjs/test/index.html` - no longer needed.
- Update .gitignore

## argmap 4.2.10

- Commit 757b6c0 (garlic0708's final mapjs commit) removed with interactive rebase, since part of it was breaking mapjs.

## argmap 4.2.9

- `mapjs/`:
  - Removed extra start.js files mixed up from `mapjs-example/`.
  - Fix differences between `test/start.js` vs original, now working, though UI seems flakier than `mapjs-example/`.
  - Move `test/start.js` to `src/start.js` since it's a source file.
  - `package.json`: Add  "type": "commonjs".
  - Remove references to `src/example-map.json` from `src/start.js`
  - Delete `test/example-map.json`
- Update `.gitignore`, including update from upstream mapjs repo.

## argmap 4.2.8 General Improvements

- Fix `scripts/install.sh`, `environment.yml`.
  - Introduce bug in conda section, fixed in v4.3.2
- Restore missing example test to `test/input`.

## argmap 4.2.7 TEST

- Installed critical packages

## argmap 4.2.6 TEST

- Testing `/mapjs` instead of `/example-mapjs` to see if it fixes some security errors.

## argmap 4.2.5

- Give test controls class and unique IDs:
  - `src/pandoc-argmap.lua`
  - `pandoc-templates/mapjs/mapjs-testcontrols.html`
- `.vscode/launch.json`: Add url debug profile, with flag for opening local files included.
- Rename these uses of argmaps to argmap for consistency:
  - `scripts/argmap_init_script.sh`
  - env variable `CONDA_ENV_ARGMAP`

## argmap 4.2.4

- Fix html output URLs - use relative URLs:
  - Restore `mapjs.env` files e.g. `mapjs-example/scripts/mapjs.env`.
  - Various config files: Update environment variables for html resource paths to be relative.
  - `src/pandoc-argmap.lua`:
    - Add variable for JSON resource path (relative), contrasting with output folder (absolute).
    - Fix path for mapjs controls template.
- Rationalise env variables:
  - Standardise env variable naming convention.
  - Create env variable: `DIR_HTML_OUTPUT` and add where needed.
  - Fix some incorrect paths missed from output folder changed in v4.2.1
  - Simplified logic in `src/pandoc-argmap.lua`
- `scripts/git_hooks/pre-commit`: Add webpack rebuild before testing.
- `scripts/bash_aliases_argmap.sh: md2pdf()`: Make link to pdf template absolute so function works from any folder location.
- [README.md](../README.md):
  - Update mapjs sections with instructions for v4.2.0 onwards.
  - Minor updates.

## argmap 4.2.3

Supports multiple mapjs on page:

- `mapjs-example/src/start.js`:
  - Loops through all containers.
  - ISSUE #22: Each control panel affects both maps.

## argmap 4.2.2

- Fix logic for identifying script for mapjs container:
  - `src/pandoc-argmap.lua`: Make JSON script child of relevant container.
  - `mapjs-example/src/start.js`:
    - Identify script relative to container rather than using ID.
    - Remove script ID since no longer necessary.

## argmap 4.2.1

- Create all html, JSON and png output in `test/output/`.
  - `mapjs-example/src/start.js`: Above, plus rename functions more logically.
  - `scripts/install.sh`: Remove symbolic link to `test/output` folder.
  - Update env variables in script files.
  - Delete mapjs.env files.
  - Rename `MAPJS_JSON_INPUT_DIR` to `MAPJS_JSON_DIR`.
- Add alias `argth` to run html output tests only.
- Remove `pandoc-templates/pandoc_html5_template.html` since unnecessary (was added for reference).

## argmap 4.2.0

- Generate argmap mapjs without webpack rebuild:
  - `mapjs-example/src/start.js`:
    - Load mapjs JSON file asynchronously using fetch().
    - Tidy comments.
  - `src/pandoc-argmap.lua`: Reference JSON file with `application/json` script.
  - `scripts/bash_aliases_argmap.sh`:
    - `__open-mapjs()`:
      - Rename `__chrome-mini()` to `__open-mapjs()`.
      - Add `--allow-file-access-from-files` to chrome call to avoid CORS origin error from Chrome accessing JSON file locally.
        - [README.md](../README.md): Document above workaround.
    - `__build_mapjs`: Only call when code changes, rather than for each new argmap:
      - Rename `__pack_mapjs` to `__build_mapjs`.
      - Add it to `scripts/install.sh`, remove it from other functions.
      - Deprecate `a2jo()`, do not export it and `a2mo` so they are not available to other scripts.
        - `scripts/tests.sh`: Remove test #5 (obsolete, uses a2jo).
        - `test/bash_aliases_argmap_test.sh`: Remove alias `argmj`.

## argmap 4.1.0

- `src/pandoc-argmap.lua`:
  - Set default `to:` in .md metadata using `argmap: to: X`.
    - See `test/input/Example1_ClearlyFalse_WhiteSwan_simplified_meta_mapjs.md` for example.
  - Re-factor.
- Update [README.md](../README.md).

## argmap 4.0.0 BREAKING

- Change block directive from `convertTo="mapjs"` to `to="js"` for consistency with pandoc. BREAKING
  - Update: `src/pandoc-argmap.lua`, example files.
- Write all mapjs .json input files to `MAPJS_JSON_INPUT_DIR`: BREAKING
  - Initialise in init_script as `output/mapjs-json-input`.
  - Read in `config_argmap.lua`
  - Update `src/pandoc-argmap.lua` to output json code to this folder.
  - Update `scripts/install.sh` and symbolic link: link to `mapjs-example/`.
- `tests/tests.sh`:
  - Fix duplicate argmap IDs in some test files.
  - Add 2 `md2hf()` tests for new input files with 0, 2 argmap > mapjs code blocks.
  - Add `md2hf()` test for new input file with argmap > mapjs metadata.
  - `scripts/bash_aliases_argmap.sh`:
    - `md2hf()`:
      - Fix browser blocking test progression with `&disown`.
      - Write html output to different files, avoiding shared test state while waiting for browser.
      - Update `__clean_repo`.
- Update scripts to use `test/input` and `test/output` instead of `Input` and `Output`.
  - Move `Input` test files to above folders.

## argmap 3.9.2

- `bash_aliases_argmap.sh`: Update `md2htm()` to output only html doc fragment.
- `test/`:
  - Add folders: input, output, issues
    - Move any test files to these folders from `Input/` and `Output/` which won't break scripts.

## argmap 3.9.1

- [README.md](../README.md):
  - Update mapjs link in introduction to refer to internal section instead of github.
  - Improve clarity of some sections.

## argmap 3.9.0

- `test/`:
  - Add folder to use for tests related scripts.
  - Move 'tests.sh' from `scripts/` to here.
  - Create `test/bash_aliases_argmap_test.sh`.
- `scripts/`:
  - `bash_aliases_argmap.sh`: Move all aliases to `test/bash_aliases_argmap_test.sh` since they are all tests.
  - `scripts/argmaps_init_script.sh`: Source `test/bash_aliases_argmap_test.sh`
- Docs, scripts, rockspec:
  - Update references to both above scripts.
  - Add mentions that test files are not public api.
- `.vscode/launch.json`: Fix broken path to example file due to 3.8.3 bug.
  
## argmap 3.8.3

- `Input`:
  - Duplicate and rename `Example1_ClearlyFalse_WhiteSwan_simplified.md` to have variants with 0,1,2 mapjs references, and add them to repo.
- `scripts/`:
  - `argmaps_init_script.sh`: Add above to INPUT_FILE aliases.
  - `scripts/bash_aliases_argmap.sh`: Add above to argm aliases.
- `mapjs-example/src/start.js`: Only generates mapjs if mapjs snippets found.
- `Input/example-updated.md`: Add copy of `examples/example.md` modified to work with mapjs.

BUG:

- `.vscode/launch.json`: Broke path to example file.

## argmap 3.8.2

- `scripts`
  - `bash_aliases_argmap.sh`:
    `__pack_mapjs()`: Remove env variable argument since specific .json files no longer requested during webpack build process.
- `mapjs-example/webpack.config.js`: Remove env variable functionality.
  
## argmap 3.8.1

- `scripts`:
  - Rename 'private' functions to start with __
  - Move `git_hooks` folder into `scripts`.
    - Update `install.sh`
  - Re-organise some functions.
- Update docs to explain private functions may change during patch updates.

## argmap 3.8.0

- `src/pandoc-argmap.lua`: Update to convert argmap code blocks with attribute `convertTo="mapjs"` to mapjs format.
- `mapjs-example/src/start.js`:
  - Now requires map.json dynamically.
  - `init()` now takes map.json path as second argument or can read it from container `src` attribute.
- [README.md](../README.md):
  - Add info about generating html containing mapjs format in section ['Embedding Maps in Markdown'](../README.md#embedding-maps-in-markdown).
    - Add `docs/mapjs-in-html-example.png`.
    - Explain `convertTo="mapjs"` functionality.
  - Fix code formatting for latex code block examples.
  - Fix argmap code block examples to display relevant attributes.
- Add references in various places to [mapjs .json Data Format](https://github.com/mindmup/mapjs/wiki/Data-Format) on the mapjs wiki.
- `scripts/`:
  - `bash_aliases_argmap.sh`:
    - Add new functions:
      - `md2hf()`:
        - Generates index.html from pandoc template and generates mup.json with webpack.
        - Fix bug with template parameter using relative path.
        - BUG #21: Hanging when calling `argmh` when browser already open. Not sure when introduced.
      - `chrome-mini`: Utility function.
    - Update md2htm() to use custom mapjs html5 template now available in pandoc data folder.
    - Remove unnecessary calls to webpack from some functions now `pandoc-argmap.lua` creates output files.
  - `tests.sh`:
    - Use init file variables instead of own.
    - Fix test #6 to use newer html function.
- `Input/`:
  - `Example1_ClearlyFalse_WhiteSwan_simplified.md`:
    - Use two code snippets, one for png output and one for mapjs.
    - Add meta-data for use in template.
- `.vscode/launch.json`:
  - Add `cat X | argmap2mup` profile.
  - Fix html output profile.
  - Update pandoc test to use my own example files.

## argmap 3.7.1

- Add `pandoc-templates` folder containing:
  - Two html5 templates: pandoc default, and custom mapjs:
    - `custom-mapjs.html5` template based on default combined with mapjs `index.html` file.
    - `mapjs-map.html`: Move script and style to `mapjs-main-html5.html` since they only need to appear once regardless of number of containers.
    - pandoc partials (sub-templates) for parts of custom template.
      - `pandoc-templates/mapjs/mapjs-map.html`:
      - Add temporary `src` attribute to container.
- mapjs folders:
  - Add `scripts/mapjs.config` to `mapjs` and `mapjs-example` folders and source these from argmap init script so that correct files are referenced for each.
  - Move to `mapjs-example/`:
    - `scripts/`:
      - `scripts/argmaps_init_script.sh`:
        - Fix bugs when terminal opens outside of WORKSPACE.
        - Clean up variable references and delete GIT_PROJECT_DIR.
          - Remove GIT_PROJECT_DIR definition from `environment.yml`.
        - Add input file variables for each file type.
      - `install.sh`: Add symbolic link from pandoc data folder to `pandoc-templates`.
    - `pandoc-templates/mapjs/mapjs-map.html`: Add metadata variable: $mapjs-output-js$
    - Update scripts to use variable MJS_WP_HOME properly.
  - Add `mapjs-example/src/argmap_output/` for maps data:
    - Symbolic links to `Output/` folder.
    - Update paths used in `src/start.js`.
  - Select containers based on .container not #container.
    - `mapjs-example/src/start.js`
    - `mapjs/mapjs-inline-styles.css`
  - `package.json`: Add `"type": "commonjs"`.
- `src/`:
  - `argmap2mup.lua`: Stop public flag forcing upload to ensure uploads deliberate.
  - `config_argmap.lua`: Move logging functionality here for centralisation.

## argmap 3.7.0

- Develop argmapjs prototype:

  - Merge with local custom branch of repo [`s6mike/mapjs-webpack-example at custom`](https://github.com/s6mike/mapjs-webpack-example/tree/custom). See [README.md](../README.md#using-mapjs-to-display-argmaps) for more details.
    - mapjs project files are in `mapjs` folder.
    - `scripts`:
      - `scripts/bash_aliases_argmap.sh`:
        - Add `a2jo` function and `argmj` alias to generate .json file and open with mapjs.
        - Rename `mappack` function to `pack_mapjs` and add argument to pass onto webpack build.
        - Fix bug from calling chrome alias instead of chrome-browser directly, blocking command line parameters.
        - Remove output redirect from webpack calls, set webpack.config.js to report build errors only.
      - `scripts/install.sh`: Add npm install command.
      - `scripts/argmaps_init_script.sh`:
        - Update 2 MJS_WP_X variables to match new mapjs folder location and to reference new `examples/example.json`.
        - Fix bugs when terminal opens outside of WORKSPACE.
        - Clean up variable references and delete GIT_PROJECT_DIR.
          - Remove GIT_PROJECT_DIR definition from `environment.yml`.
        - Add input file variables for each file type.
      - `tests.sh`: run test for `a2jo` instead of `a2mo`.
      - `install.sh`: Add symbolic link from pandoc data folder to `pandoc-templates`.
    - Add `examples/example.json` (generated from example.yml) to repo as an example for mapjs.
    - Remove commands to delete MJS_WP_MAP which is now `examples/example.json`
  
    - See [CHANGELOG-mapjs.md](mapjs/docs/CHANGELOG-mapjs.md) for more details.
    - [README.md](../README.md):
      - Add mapjs and troubleshooting sections.
      - Add `docs/mapjs-example.png` to repo for use in [README.md](../README.md).
    - git hook `hooks/pre-commit`:
      - Add to repo, in `hooks` folder (symlinking to it from .git/hooks/pre-commit), to keep it in sync with rest of repo.
        - Add symlink command to `scripts/install.sh`.
      - Update MJS variables to reflect new mapjs folder and example file.
      - Source init_script rather than defining variables independently.
  - Other minor documentation updates.

## argmap 3.6.0 Release Version

- Update to pandoc 2.9.2.1-0:
  - Update `environment.yml`
  - Update [README.md](../README.md)
  - Add comments re available pandoc variable to `src/pandoc-argmap.lua`
  - Update `scripts/install.sh` to link to new pandoc data directory location (`$HOME/.local/share/pandoc`).
  - Update rockspec for release.
  
## argmap 3.5.3

- `.vscode`:  
  - `launch.json`: Update argmap2mup gdrive upload debug profile to use correct lua install.
  - `settings.json`: Update lua extension settings.
- `scripts/install.sh`:
  - Add symbolic link so vscode-pandoc extension can find `config_argmap.lua`.
  - Move `chmod src/*` into section 2 since it will be needed by all users.

## argmap 3.5.2 Release Version

- Update rockspec for release.
- `scripts/luarocks_clean.sh`: Find rockspec filename before trying to delete it.
- [README.md](../README.md): Remove reference to rockspec version number to simplify maintenance.

## argmap 3.5.1

- `scripts/`:
  - `qa_rockspec.sh`: Use environment variable in rockspec install command.
  - `install.sh`: Call `qa_rockspec.sh` to install Lua dependencies.
- `.vscode/settings.json`:
  - Fix incorrect pandoc data folder path for [MPE extension](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced).
  - Remove some duplicates in lua path variables.
- [README.md](../README.md): Manage expectations regarding use of semantic versioning.

## argmap 3.5.0

- Add `scripts/qa_rockspec`: lints and makes rockspec to ensure validity.
- Update rockspec for release, and to include external yaml dependency.

## argmap 3.4.0

- New script function: check_repo: Checks `src/` for lua files with leftover test/debug code.

## argmap 3.3.1

- New conda env argmap:
  - Clean up `LUA_PATH` and `LUA_CPATH`, which both had invalid paths.
  - Remove extra dependencies so only deliberate installs included. Should be more platform independent.
  - Rename relevant variables in vscode settings etc.
  - Update `scripts/install.sh` to use `$CONDA_PREFIX`.
  - `.vscode/settings.json`:
    - Add missing $ to variables, must have been wrong for a while.
    - Added variable to [MPE](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) extension setting.

## argmap 3.3.0

- Use more variables to reduce duplicate paths etc:
  - `.vscode/launch.json`
  - `.vscode/settings.json`
  - Add `src/config_argmap.lua` to ensure LUA_PATH etc available to VSCode extensions.
  - Update scripts:
    - Including symbolic link in `scripts/install.sh` to ensure `src/config_argmap.lua` available in `~/.local/share`.
- Fix missing image issue: relates to #20:
  - Update bash aliases to move image file for `tests.sh`
  - Add Input/12ff...png to repo for VSCode extension html output tests.

## argmap 3.2.2

`src/pandoc-argmap`:

- Fix crash on 2 README md to pdf examples, close #19.
  - Add first one to test file to ensure no regressions.
  - Add second to aliases.

`src/argmap2tikz.lua`:

- Fix lint errors: close #6, #7, #8.

## argmap 3.2.1

- [README.md](../README.md): Update sections: fork details and installation.
- Update `.vscode/launch.json` to use more settings variables for portability.
- Add workspace settings.json to repo to track these settings.
- Add failing md to pdf test to argmap aliases script.
- Add `.mup` Input file to repo for tests.
- `.gitignore`: Add examples and Input to keep stable. Plus archive folder for reference files.
- Minor formatting updates.

## argmap 3.2.0 Release Version

- Lua Code:
  - Move to src folder.
  - Restore line 1 #! shebang directive to lua scripts ([Local Lua Debugger - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode) works with them).
  - [README.md](../README.md): update examples to correctly call lua files.
  - Add src folder to LUA_PATH in conda environment.yml.
  - Fix pandoc-argmap so it works.
  - Updated rockspec and `scripts/install.sh` to reflect new rockspec dependency.
- Pandoc:
  - Downgrade pandoc to v2.6:
    - [README.md](../README.md): update to reference this version.
    - `environment.yml`: Downgrade pandoc to v2.6, which was hopefully version used to develop pandoc-argmap.lua
  - `src/pandoc-argmap.lua`:
    - Fix references to local .lua commands (argmap2mup etc).
    - Fix 'need check nil' and undefined globals lint warnings, relates to #7, #8.
    - Make formatting consistent.
    - Add debug logging.
    - Fix launch.json debug configurations.
- Scripts:
  - Add `md2h` command to convert markdown with embedded argmaps to html, using filter `src/pandoc-argmap.lua`.
  - And `a2t` command to convert argmap yml into tex, using argmap2tikz.
    - Add aliases to run both of them.
    - Add them both to tests script.
  - Make scripts more portable with env variables: can change folder locations and conda env.
  - Move environment variable definitions from bash aliases, to conda env, init_script and conda.env
  - Add `scripts/install.sh` for symbolic links to lua files, to help reproduce install config consistently and avoid recent path issues.
  - No longer use lua or .lua in calls due to above lua code changes plus use of symbolic links.
  - Add `conda.env` to set conda env name variable so it's easy for pre-commit hook to access.
  - Add pandoc bash completions to init script.
- Add some additional Input and Output examples.
- Add Input and example folders to .gitignore now sufficient examples in repo.

## argmap 3.1.11

- [CONTRIBUTIONS.md](../CONTRIBUTIONS.md): Update for clarity.

## argmap 3.1.10

- [CONTRIBUTIONS.md](../CONTRIBUTIONS.md): Update for clarity.

## argmap 3.1.9

- Update tests.sh to work when called from pre-commit hook:
  - Exit code set to fail when a test fails.
  - Don't use ANSI colour escape code when dumb terminal.

## argmap 3.1.8

- Docs:
  - Add Tables of Contents.
  - Refine collapsible section formatting, default to open so ToC links work.
  - Improve formatting using markdown linter suggestions.
  - Update for clarity.

## argmap 3.1.7

- Shell scripts:
  - Fix lint issues using shellcheck and shell-format suggestions.
  - Make tests.sh output command success cleanly.
- Update environment.yml to include more dependencies.
- Change Log: Improve formatting using markdown linter suggestions.

## argmap 3.1.6

- [README.md](../README.md):
  - Make collapsible sections more obvious.
  - Fix broken code example.
- [CONTRIBUTING.md](../CONTRIBUTING.md): Improve formatting, layout and wording.

## argmap 3.1.5

- [README.md](../README.md):
  - Fix headline map link to link to published version (should be available until Jan 2023).
  - Make some sections collapsible: Installation, Syntax Rules and pandoc-argmap.lua
  - Add reference to issue 11: generated .mup files don't always work on mindmup, but can be used with legacy mindmup.
- example/example.yml: Update to match documentation.

## argmap 3.1.4

- launch.json:
  - Update filenames to include .lua extension.
  - Comment out sourcemap references, since unnecessary.

## argmap 3.1.3

- [CONTRIBUTING.md](../CONTRIBUTING.md): Fix broken links and typos.

## argmap 3.1.2 Release Version

- Update test.sh script to delete output files directly before test.
- Update clean function:
  - Rename as clean_repo.
  - Update to revert Output folder to match remote branch.

## argmap 3.1.1

- Docs:
  - Add docs folder.
  - Rename change log from NEWS.md to docs/CHANGELOG.md.
  - Add [CONTRIBUTING.md](../CONTRIBUTING.md).
  - Fix readme examples: now commands have .lua file extension.
- Fix rockspec to use correct version number.
- Add luarocks library clean-up file to simplify install testing.

## argmap 3.1.0

- Add rockspec file.
- Replace dependency json.lua with rxi-json-lua.lua for simpler install.
- Update conda env with values from luarocks path.
- Update readme install instructions.
  - Rename to [README.md](../README.md): simplifies rockspec generation.
- Add tests.sh file to do minimal testing.

## argmap 3.0.1

- Update bash aliases:
  - Add bash function for uploading to gdrive.
  - Upload to GDrive folder 'argmap_uploads'.
  - Use input filename as upload filename.

## argmap 3.0.0 BREAKING

- BREAKING: Add .lua file extension to lua app files to ensure correct syntax highlighting. Readme examples still need updating.
- Add argmap_init_script.sh and bash_aliases_argmap.sh to keep bash config and convenience functions in sync with code.

## argmap 2.1.0 Release Version

- Install lualogging to help with debugging.
  - Add debug logging to mup2argmap.
- Add launch.json to repo to track debugging tests.
- Fix mup2argmap:
  - Fix global variable which could be local, relates to #5, #6.
  - Fix need check nil, relates to #7.
- Fix argmap2mup:
  - Close #3 Static analyser errors.
- Comment out line 1 #! directive, so actboy168's lua debug extension can handle breakpoints: (see <https://github.com/actboy168/lua-debug/issues/153>).
  - Call explicitly with lua instead.
- Fix formatting based on sumneko's vscode lua extension.
- Add my own reference examples, in Input and Output folders.
- Readme: add github compatible syntax highlighting directives.

## argmap 1.1.0

- Fork of <https://github.com/dsanson/argmap>
- argmap2mup fix (potentially caused by different lua version):
  - Close #1 output file start with 'nil'.
  - Close #2 gdrive upload fails.
- Update license and readme.
- Add .gitignore, conda export: environment.yml

## argmap 1.0.1

- Update [README](README.md), [license](LICENSE).
- Add this CHANGELOG.md file.

## argmap 1.0.0

Original <https://github.com/dsanson/argmap>

-------------------------

Uses [Semantic Versioning 2.0.0](https://semver.org/) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Note that test files, and bash script functions beginning with __ are not considered part of a public API, and therefore updates may change them without warning.

Though documentation is not yet precise and comprehensive! Lua code is well documented, but my scripts still need to be properly documented.
