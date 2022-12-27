# Argmap Project Change Log

## TODO

- Remove buttons:
  - `Parent reason`: Since it's not really useful:
    - `mapjs/src/browser/map-toolbar-widget.js`: Remove from clickMethodNames array.
    - `mapjs/src/core/map-model.js`: Remove functionality.
- [README.md](../README.md):
  - Add note about linking/using templates (html and latex) with pandoc.
  - Add references to argmap specs spreadsheet?

## argmap 5.0.16

- `mapjs/src/argmapjs-utilities.js`: Update comment.

## argmap 5.0.15

- Remove `mapjs/packages/core-dependencies/package.json` since it seems unnecessary.

## argmap 5.0.14

- Add `.editorconfig` for consistent formatting.

## argmap 5.0.13

- Fix `mapjs/package.json` to refer to this repo rather than original mindmup repo.
  - Update `mapjs/package-lock.json` to match.

## argmap 5.0.12

- Update rockspec for new release: `argmap-5.0.12-12.rockspec`

## argmap 5.0.11

- `src/client_argmap2mapjs.lua`: Add comment

## argmap 5.0.10

- Update all mapjs dependencies to latest except `jquery-hammerjs` (`mapjs/package.json` and `mapjs/package-lock.json`).

## argmap 5.0.9

- Disable drag and drop when edit mode disabled (`Disable` button):
  - `mapjs/src/browser/hammer-draggable.js`: Node drag and drop.
  - `mapjs/src/browser/image-insert-controller.js`: Image drag and drop.
  - `mapjs/src/start.js`: Mapjs JSON drag and drop.
  - `mapjs/src/argmapjs-utilities.js`: Helper function to get current mapjs container id when passed an event or element.

## argmap 5.0.8

  -`test/test_scripts/tests.sh`:
    - 2 test recordings still not working consistnetly in Testcafe, so commenting out.
    - Update to use new env variables.

## argmap 5.0.7

- `scripts/install.sh`: Remove any leftover symbolic links before replacing with new ones.

## argmap 5.0.6

- `scripts/bash_aliases_mapjs.sh`: Fix `__test_mapjs_renders()` bug.

## argmap 5.0.5

- `pandoc-templates/mapjs/mapjs-testcontrols.html`: Ensure background text input not separated from label by wrapping in label and using `.wrapper` class.
  - `.wrapper` already set to have style `white-space: nowrap;` in earlier change to `mapjs/public/mapjs-default-styles.css`.

## argmap 5.0.4

- `mapjs/src/browser/map-toolbar-widget.js`: Align `clickMethodNames` with toolbar layout.

## argmap 5.0.3

- Delete obsolete debug profile.

## argmap 5.0.2

- Delete obsolete rockspec: `argmap-4.18.10-10.rockspec`.

## argmap 5.0.1

- Rename `mapjs/site` folder as `mapjs/public`.
- Rename container template partial as `pandoc-templates/mapjs/mapjs-map-container.html`
- Update everything impacted by these changes.

## argmap 5.0.0

BREAKING

- `mapjs/src/browser/dom-map-widget.js`: Change keyboard shortcuts for add sibling before and after to: `,` and `.`
  - [mapjs/README.md](../mapjs/README.md): Update documentation to reflect this.
  - Update `test/devtools-recordings/argmap-edit-first-child.json` to use new keyboard shortcuts.
- `pandoc-templates/mapjs/mapjs-testcontrols.html`: Remove buttons from toolbar:
  - `Export to image`, 'Frames' and 'Cycle': Since I can't find their functionality.
  - Also remove `editIcon()` related functionality and keyboard shortcut: `mapjs/src/core/map-model.js`
- Remove legacy / deprecated functions and scripts:
  - `mapjs/package.json`
  - `scripts/bash_aliases_argmap.sh`
  - `scripts/bash_aliases_mapjs.sh`
  - `test/test_scripts/bash_aliases_argmap_test.sh`
  - `test/test_scripts/tests.sh`

## argmap 4.21.43

- `argmap-4.21.43-11.rockspec`: Add new release version.

## argmap 4.21.42

- `mapjs/src/`: Rewrite `console.log` as `console.debug` or `console.error`

## argmap 4.21.41

- [mapjs/README.md](../mapjs/README.md): Minor improvement.

## argmap 4.21.40

- `test/test_scripts/tests.sh`: Add 4 new tests which are now working.
- `test/devtools-recordings/`:
  - Fix recordings to work with updated templates.
  - Fix broken recordings to work in Testcafe:
    - By replacing `\"` with `'`.
    - Due to it being particularly about offsetX/Y values (not sure why they are needed for Testcafe click selectors to work).
  - Add some variations on edit-link recording.
- `scripts/argmap.env`: Add new input variables for test dependencies.
- `mapjs/scripts/mapjs.env`: Fix incorrect path for `PATH_REPLAY_SCRIPT_BUTTON_ADD_LINK` and add new variables.

## argmap 4.21.39

- `mapjs/src/start.js`: Remove obsolete comments.

## argmap 4.21.38

- `mapjs/src/core/content/content.js`: Fix bug with undoing link attributes not working. Was cloning link, so undo was applied to clone, not original link.

## argmap 4.21.37

- Fix `test/devtools-recordings/argmap-edit-link.json` to work with updated quick template.

## argmap 4.21.36

- `mapjs/src/browser/dom-map-widget.js`:
  - Fix issue (4.21.30): Zooming window body in/out only works once, then focus goes to container and zooms that.
    - Zooming triggers window.resize listener which calls `resetView()` on map. No reason to reset view when window resizes so commented this out.

## argmap 4.21.35

- Minor test fixes.

## argmap 4.21.34

- Minor comment updates.

## argmap 4.21.33

- Fix `Add` button broken in 4.21.28:
  - `mapjs/src/browser/map-toolbar-widget.js`: `clickMethodNames` checks whether `DOMMapString` is empty, if so sets it to `undefined`.

## argmap 4.21.32

- `scripts/bash_aliases_argmap.sh`: Change default input for `md2hf()` so that output has 2 mapjs containers.

## argmap 4.21.31

- `mapjs/package.json`: Add scripts to use ':' instead of '-' e.g. `test:start`, as this is the convention. Will delete alternative version later as breaking change.
- `bash_aliases_mapjs.sh`:
  - Update `testcafe_run()` to use new package.json script `testcafe:command`.
  - Delete deprecated internal functions.

## argmap 4.21.30

- Fix zoom in/out keys to apply to container not whole document:
  - `mapjs/src/browser/dom-map-widget.js`:
    - Move keydown listener from `document` to relevant container element (`mapModel.containerElement`).
    - Use vanilla JS instead of jQuery.
  - `pandoc-templates/mapjs/mapjs-map.html`: Add tabindex="-1" to container element so it can receive keyboard events.

- ISSUE: Clicking on body then zooming in/out only works once then focus goes to container and zooms that. Fixed in 4.21.36

## argmap 4.21.29

- Fix broken enable/disable buttons, same approach as in previous commit:
  - `mapjs/src/browser/map-toolbar-widget.js`: Add `setInputEnabled` to `clickMethodNames` array.
  - `mapjs/src/core/map-model.js`: Update `setInputEnabled()` signature for compatibility with `map-toolbar-widget.js` button click handling, then read from data set to set input enabled value.
  - `mapjs/src/browser/dom-map-controller.js`: Update calls to `setInputEnabled()`  to use new function signature.

## argmap 4.21.28

- Fix broken support/oppose/parent buttons and refactor related code:
  - `mapjs/src/start.js`: Define `mapToolbarWidget` in `MAPJS` (`npm-main.js`) instead of`jQuery.fn`
  - `pandoc-templates/mapjs/mapjs-testcontrols.html`: Edit buttons with `onclick` listeners:
    - Replace `onclick` listeners with data attributes, consistent with other buttons.
    - Add classes for the function calls.
  -`mapjs/src/browser/map-toolbar-widget.js`:
    - Use`module.export` instead of `jQuery.fn`
    - Add updated buttons' classes to `clickMethodNames` array.
    - Update clickMethodNames iterator to:
      - Use vanilla JS instead of jQuery.
      - Map click listener to all buttons with the class, not just the first.
      - Pass the whole element dataset as the second argument, so compatible with target functions.

- ISSUE: This breaks the `Add` button since the empty `DOMMapString` passed as second argument breaks the `addSubIdea()` function. Fixed in v4.21.33

## argmap 4.21.27

- Update some dependencies following npm update: `mapjs/package-lock.json`

## argmap 4.21.26

- `pandoc-templates/mapjs/mapjs-main-html5.html`: Add blank line so html output cleaner.

## argmap 4.21.25

- `src/pandoc-argmap.lua`: Reads container from `pandoc-templates/mapjs/mapjs-map.html`, removes comments, substitutes the toolbar html, block_ids and JSON file path.
  - `scripts/argmap.env`: Add env variables for templates location.
  - `src/config_argmap.lua`: Read above env variables (with defaults).
  - `pandoc-templates/mapjs/mapjs-map.html`: Update container id format so lua code ID generation logic can be left as is.

## argmap 4.21.24

- `mapjs/src/start.js`: Remove `console.debug()` line.

## argmap 4.21.23

- `.vscode/launch.json`: Add lua debug profile for pandoc call with lua filter, though I couldn't get it to work.

## argmap 4.21.22

- Pretty print `test/input/mapjs-json/example-updated.json`.

## argmap 4.21.21

- `pandoc-templates/mapjs/mapjs-main-html5.html`: Add simple footer to website.

## argmap 4.21.20

- `mapjs/src/themes/argmap-theme.json`: Make supporting green darker to improve contrast and accessibility.

## argmap 4.21.19

- `pandoc-templates/mapjs/mapjs-testcontrols.html`:
  - Add aria-labels for accessibility.
  - Remove unnecessary div.

## argmap 4.21.18

- `mapjs/src/browser/dom-map-widget.js`: Add `role` and `aria-label` to svg container for accessibility.

## argmap 4.21.17

- `mapjs/src/browser/dom-map-widget.js`: Add new keyboard shortcuts for insert node left and insert node right ('alt+left', 'alt+right').
  - [mapjs/README.md](../mapjs/README.md): Update with new keys.

## argmap 4.21.16

- Update `jquery` and `npm-check-updates`: `mapjs/package.json`, `mapjs/package-lock.json`.

## argmap 4.21.15

- Upgrade npm to 9.2.0 and update `engines` field to reflect in `mapjs/package.json`, `mapjs/package-lock.json`.

## argmap 4.21.14

- Fix so keyboard shortcuts work immediately after editing node:
  - `mapjs/src/browser/dom-map-controller.js`: Put focus on svg stage after successful or aborted edit ('Esc').

## argmap 4.21.13

- Fix tab navigation by:
  - Removing tabindex from:
    - mapjs container:
      - `pandoc-templates/mapjs/mapjs-map.html`
      - `src/pandoc-argmap.lua`
    - nodes: `mapjs/src/browser/create-node.js`
    - svgContainer etc: `mapjs/src/browser/dom-map-widget.js`:
      - BREAKING: Disabling tab keyboard shortcuts (insert node left and right).
      - Adding tabindex=0 to svg stage.
- Also added trailing commas to above js files.

## argmap 4.21.12

- `test/devtools-recordings/`
  - Fix recordings broken by semantic elements being added to toolbar for accessibility.

## argmap 4.21.11

- `scripts/bash_aliases_argmap.sh`:
  - Use lower case for local variables.
  - All functions which use pandoc e.g. `j2hf()`:
    - Add `--metadata=lang:$LANGUAGE_PANDOC` to pandoc call so language always gets populated.
      - `scripts/argmap.env`: Add `LANGUAGE_PANDOC=en`.
    - Change 2nd argument to be filename rather than file path for simplicity.
    - Update to pass extra arguments (3rd onwards) to pandoc.
      - Add `j2hfa` alias for activating argmap input functionality by passing extra metadata argument.
      - Update `a2m()` to pass extra arguments (2nd onwards) to output in case piped into `j2hf()`.
      - Remove calls to `__check_server_on` if open-debug is called, since this also runs the same check.
  - Fix bug in `a2t()` so it can create folder in correct path.
  
## argmap 4.21.10

- `pandoc-templates/mapjs/mapjs-main-html5.html`: Move `argmap-input` partial to before body so it works better with markdown input.

## argmap 4.21.9

- Make templates and includes more accessible:
  - Add tags: main, article, section
  - Add roles to divs.
  - Add heading to map container include.
  - Add aria-labels to select elements.

## argmap 4.21.8

- `scripts/bash_aliases_argmap.sh`: `md2hf()`:
  - Add default input file.
  - Make local variables lower case for readability.

## argmap 4.21.7

- `mapjs/webpack.config.js`: Turn off client progress since it fills debug output, annoying.

## argmap 4.21.6

- `mapjs/webpack.config.js`: Fix webpack html output to be just scripts, no head tags, using templateContent instead of template.
  - Delete unnecessary `mapjs/src/templates/template-webpack-dist-tags.html`

## argmap 4.21.5

- `pandoc-templates/mapjs/mapjs-main-html5.html`: Combine `pandoc-templates/mapjs/mapjs-quick-json.html` into this one using meta-data boolean and if statement to selectively include quick container section.
  - `scripts/argmap.env`: Add env variable `FILE_TEMPLATE_HTML_ARGMAP` to store template location and use this in scripts.
  - `scripts/bash_aliases_argmap.sh`:
    - Update `j2hf()` to use template `pandoc-templates/mapjs/mapjs-main-html5.html` and set meta-data for quick container.
  - Delete `pandoc-templates/mapjs/mapjs-quick-json.html` now it's unused.
  - `pandoc-templates/mapjs/mapjs-map.html`: Update comments.
- Add another conditional for optionally adding the `argmap-input` functionality.
  - Update `j2hf()` and `md2hf()` to use new env variable `FILE_TEMPLATE_HTML_ARGMAP`.
  
## argmap 4.21.4

- `mapjs/site/mapjs-default-styles.css`:
  - `cursor`: For nodes change to `grab`, since pointer should only be used for links.
    - Except when editing text, then use `text` cursor.

## argmap 4.21.3

- `mapjs/site/mapjs-default-styles.css`: Add `.buttonStyle` to style the label like a button.

## argmap 4.21.2

- Use 'Load' label instead of file input element for easier styling.
  - `pandoc-templates/mapjs/mapjs-testcontrols.html`: Wrap label around file-input element; add classes for styling and interaction.
  - `mapjs/site/mapjs-default-styles.css`:
    - Add `.hide-accessibly` to position the element absolutely, hide it and stop any mouse pointer interactions with it.
      - NOTE: There are accessibility implications for all of these options, see [A new (and easy) way to hide content accessibly | Zell Liew](https://zellwk.com/blog/hide-content-accessibly/) for a discussion.
    - Add `:focus-within` for label to look like it's tab selected when actually the file input element is. This means that hitting enter will still open the file dialogue.
      This solution means the following changes are no longer necessary. Left in, in case useful later:
      - `mapjs/src/browser/map-toolbar-widget.js`: Add copmmented code for alternative solution using `keyDownEnterMethodNames()` function to loop through a new `keyDownEnterMethodNames` array and call the class as a function. This calls `handleKey_loadMap()` when tab navigation used to activate the 'Load' label.
        - `mapjs/src/core/map-model.js`: Add container parameter to `handleKey_loadMap` so it can handle enter key events on 'Load' label.
        - `mapjs/src/browser/dom-map-widget.js`: Update to use container parameter in all hotkeyEventHandler calls.

## argmap 4.21.1

- `pandoc-templates/mapjs/mapjs-map.html`: Add aria label to container div.

## argmap 4.21.0

- Load Map functionality:
  - Add `readFile` file input element to `pandoc-templates/mapjs/mapjs-testcontrols.html`
  - `mapjs/src/core/map-model.js`:
    - Add methods:
      - `readFile()`: Reads mapjs JSON file picked using `readFile` element and passes data to `loadMap()`.
      - `loadMap()`: Loads the file data as a new map.
      - `handleKey_loadMap`: Triggers file picker when `alt+o` pressed.
  - `mapjs/src/start.js`:
    - Move `loadMap()` to here from `mapjs/src/core/map-model.js`.
    - Add reference to `content()` to `mapModel` object: hacky way to allow calls to `content()` from `loadMap()`.
  - `mapjs/src/browser/map-toolbar-widget.js`:
    - Add `readFile` to `changeMethodNames` so picking a file reads it.
    - Pass event object to all `clickMethodNames` calls.
  - `mapjs/src/browser/dom-map-widget.js`:
    - Add `alt+o` keyboard shorcut to call `handleKey_loadMap()`.
      - Pass event object to all `hotkeyEventHandlers` calls.
    - [README.md](../mapjs/README.md): Add `alt+o` keyboard shortcut.
  - `src/client_argmap2mapjs.lua`: Add TODO comment for when this is re-introduced.

## argmap 4.20.6

- `pandoc-templates/mapjs/mapjs-testcontrols.html`: Populate missed `aria-label` for `updateStyle` input element.

## argmap 4.20.5

- `mapjs/src/argmapjs-utilities.js`: Fix bug in `downloadToFile()` caused by calling `removeChild()` on revoked element.

## argmap 4.20.4

- `includes/argmap-head-element.html`: Fix accessibility warning in both templates' viewport settings.

## argmap 4.20.3

- `pandoc-templates/mapjs/`: Replace head element in both templates with partial `includes/argmap-head-element.html`.

## argmap 4.20.2

- `mapjs/webpack.config.js`: Turn overlay off and progress on.

ISSUE with zooming in two maps present, though focus doesn't leave element when zooming.

## argmap 4.20.1

- Move argmap input html out of `pandoc-templates/mapjs/mapjs-quick-json.html` and into `includes/argmap-input.html`, including it as a partial.
  - Comment it out for now.

## argmap 4.20.0

- Save Map functionality:
  - Add `downloadToFile()` utility function to `mapjs/src/argmapjs-utilities.js`
  - Add `Save` button to `pandoc-templates/mapjs/mapjs-testcontrols.html`
  - Add `saveMap()` to `mapjs/src/core/map-model.js`
    - Add it to `clickMethodNames` in `mapjs/src/browser/map-toolbar-widget.js`
    - Add `alt+s` keyboard shorcut to `mapjs/src/browser/dom-map-widget.js` and [README.md](../mapjs/README.md)

## argmap 4.19.1

- `pandoc-templates/mapjs/mapjs-testcontrols.html`: Tidy up html and add aria-label (usually matching value, to be refined later) to all input elements.

## argmap 4.19.0

- `scripts/bash_aliases_mapjs.sh`:
  - Add functions and aliases:
    - `__check_server_on()` to start webserver if it's off. Uses new `SERVER_ON` variable, which unfortunately doesn't know devServer state. There should be built in variable but can't see it.
    - `webpack_server_halt()` to turn webserver off and set new `SERVER_ON=false`.
  - Update functions:
    - `webpack_server_start()` to set `SERVER_ON=true`.
    - Other functions to use new functions above.
- `scripts/bash_aliases_argmap.sh`: Update all commands which open a browser to call `__check_server_on()` first.
- `scripts/` and `test/test_scripts`: Update to use new functions above, comments, minor formatting improvements.
  
## argmap 4.18.15

- `mapjs/webpack.config.js`: Update config so live reloading works (filename has to be `[name].js`), and remove watch mode options to avoid annoying warning when serving.

ISSUE: This means no hashing to avoid caching issues, so will need to fix this before production ready.

## argmap 4.18.14

- `scripts`:
  - `scripts/bash_aliases_mapjs.sh`: Add function dependencies from general bash scripts.
  - `scripts/bash_aliases_argmap.sh`: Minor fix and tidy up.

## argmap 4.18.13

- `test/test_scripts/tests.sh`: Update to use `webpack_server_start()` instead of deprecated `__start_mapjs_webserver()`.

## argmap 4.18.12

- `mapjs/webpack.config.js`: Move `publicPath` to be output parameter for tidyness.

## argmap 4.18.11

- Check in symbolic link for `mapjs/site/output` folder to `test/output`.
  - Update `.gitignore` to allow this.

## argmap 4.18.10

- `argmap-4.18.10-10.rockspec`: Update rockspec to reflect new release version.

## argmap 4.18.9

- Update all packages to latest except `jquery-hammerjs`.

## argmap 4.18.8

- `mapjs/webpack.config.js`:
  - Add `contenthash` to output, to ensure old versions not cached.
  - Add `moduleIds: 'deterministic'` to ensure hash only changes when content changes, not when module install order changes.

## argmap 4.18.7

- `test/test_scripts/tests.sh`: Increased timeout for webpack html partial creation, since this dependency was failing tests when js needed to be rebuilt.

## argmap 4.18.6

- `test/input/html`: Remove obsolete html test input files now that mapjs source js can change more frequently.
  - Update remaining input files to use current scripts, plus some script comments.

## argmap 4.18.5

- `mapjs/webpack.config.js`: Update comments.

## argmap 4.18.4

- `scripts/bash_aliases_argmap.sh`:
  - Fix file path bug in `j2hf()` and refactor, using `get-site-path()`, so that it works when called from outside root directory.
  - Tidy up comments.

## argmap 4.18.3

- Make tests more robust by using npm package `wait-for` to wait for files to be ready for test:
  - `test/test_scripts/tests.sh`: Add `wait-for` calls in relevant places.
  - `package.json`, `package-lock.json`: Add `wait-for`.

## argmap 4.18.2

- Use html output files in all devtools recordings so that latest js
always used.

## argmap 4.18.1

- `mapjs/webpack.config.js`: Split output into main and vendor js files.

## argmap 4.18.0

- `mapjs/webpack.config.js`: Generate html partial `includes/webpack-dist-tags.html` containing script tags only, using `template-webpack-dist-tags.html`.
  - `package.json`, `package-lock.json`: Add template as dependency.
  - Add `mapjs/src/templates/template-webpack-dist-tags.html` for generating the html partial.
- Update 2 pandoc templates to use this partial instead of `mapjs-output-js` meta data.
- `.gitignore`: Ignore the html partial since it's generated, and will change regularly anyway.
- `mapjs/scripts/mapjs.env`: Add `DIR_MJS_JS` and remove `FILE_MJS_JS`.
- `scripts/bash_aliases_argmap.sh`:
  - Add `get-site-path()` using code from `open-debug()`.
    - Refactor `open-debug()` to call above function.

## argmap 4.17.10

- Tidy files: `mapjs/package.json`, `.gitignore`.

## argmap 4.17.9

- `scripts/bash_aliases_argmap.sh`: Update `md2pdf()` to open output in debug browser, for consistency and to avoid error messages from default linux chrome profile.

## argmap 4.17.8

- Fix tests, need to use output file rather than input, to ensure using latest js:
  - `scripts/argmap.env`:
    - Add env variable for output file.
  - `test/test_scripts/tests.sh`:
    - Add `j2hf()` command to create test html file needed for Testcafe tests.
    - Add warning that if Testcafe tests all fail that it might be due to input JSON mup file missing.
  - `scripts/install.sh`: Update symbolic link `mapjs/site/index.html` to point to file in output folder not input.
  - Update `test/input/html/example1-clearly-false-white-swan-simplified.html` to use newer template.

## argmap 4.17.7

- `scripts/bash_aliases_mapjs.sh`: Update `testcafe_run()` to disable extensions, in order to fix error messages from some of them.

## argmap 4.17.6

- `scripts/bash_aliases_argmap.sh`: Update `md2hf()` to use debug browser profile by calling `open-debug()` instead of default linux one.

## argmap 4.17.5

- `mapjs/webpack.config.js`:
  - Add `clean: true` to ensure obsolete files removed.
  - Update entry to use `path.resolve(__dirname)` to make it more robust.
  - Removed unnecessary comments.
  - Added dangling commas for easier maintenance.

## argmap 4.17.4

`mapjs/.eslintrc.json`: Update rules so dangling commas are (only) allowed in multi-line objects and arrays.

## argmap 4.17.3

- `mapjs/webpack.config.js`:
  - Put rules at end of file for easier reading.
  - Set watch mode to true and set dev server to watch `src/**.js` so that any mapjs changes will automatically apply to next brower reload.
    - `mapjs/package.json`: Add `&` to webpack command so that watch mode doesn't block terminal.

## argmap 4.17.2

- `mapjs/package.json`: Change `main` field to `browser`, since the package is intended for clientside use only.

## argmap 4.17.1

- `mapjs/src/browser/image-drop-widget.js`: Replace some jQuery calls with vanilla JS.

## argmap 4.17.0

- `mapjs/src/start.js`: Can drag mup JSON onto a node to add it to the node. Otherwise it will follow previous behaviour and be added as a new root.

## argmap 4.16.29

- `mapjs/src/browser/image-drop-widget.js`: Fix 2 bugs:
  - Broken drag and drop (both images and mup JSON), threw console error `Uncaught ReferenceError: map is not defined webpack-internal:///./src/browser/image-drop-widget.js 9 32 ReferenceError: map is not defined`. Think it was introduced around v4.16.8.
  - Broken undefined check which was introduced in v4.11.0 when drag and drop border first added. This broke mup JSON drag and drop from around when above issue was introduced.

## argmap 4.16.28

- `mapjs/package.json`: Add `engine` field to set current npm and node version.
  - node version matches environment.yml, but npm version not set anywhere, which is why I'm tracking it here.
  - `mapjs/package-lock.json`: This now uses `"lockfileVersion": 3,`, not sure implications.

## argmap 4.16.27

- `argmap-4.13.22-9.rockspec`: Update tinyyaml dependency to 0.4.3, so no issue with terminating string `...`.

Should have updated rockspec to 4.16.27-10. Updated in v4.18.10

## argmap 4.16.26

- `mapjs/package.json`: Make `npm-check-updates` a dev dependency.
  - `mapjs/package-lock.json`: Update to reflect above change.
- `mapjs/stats.json`: Update webpack bundle analysis report.

## argmap 4.16.25

- Update `exports-loader` to 4.0.0:
  - Remove `exports-loader` call from `mapjs/src/browser/hammer-draggable.js` and add to `mapjs/webpack.config.js` using latest API.
- Update [mapjs/README.md](../mapjs/README.md) to explain that latest `jquery-hammerjs` (v2.0.0) introduces an insecure version of jQuery so using previous version (v1.1.3) instead.
  - Update [README.md](../README.md) to refer to above README.

## argmap 4.16.24

- Update `imports-loader` to 4.0.1:
  - Remove `imports-loader` call from `mapjs/src/browser/dom-map-widget.js` and add to `mapjs/webpack.config.js` using latest API.

## argmap 4.16.23

- `mapjs/package.json`: Update all dependencies to latest version except `jquery-hammerjs`, `exports-loader` and `imports-loader`, which all throw build errors when upgraded to latest version.
  - Update `mapjs/package-lock.json`.

## argmap 4.16.22

- Fix last few lint errors:
- `mapjs/webpack.config.js`: Fix lint error for env variable `process`.
- `mapjs/specs/browser/update-stage-spec.js`: Indentation.

## argmap 4.16.21

- `mapjs/package.json`: Update scripts `start` and `server` to call `webpack serve` instead of `webpack-dev-server`.

## argmap 4.16.20

- `mapjs/specs/core/content/content-spec.js`: Fix regex error reported by codeQL.

## argmap 4.16.19

- Add `.github/workflows/codeql.yml` so github scans js code for issue.

## argmap 4.16.18

- `mapjs/package.json`: Replace source for `jquery.hotkeys`: use npm `^0.1.0` instead of github.
  - Update `mapjs/package-lock.json`.

## argmap 4.16.17

- `mapjs/package.json`: Add `env` script to check npm env variables:
  - Use `npm run env | grep npm`.

## argmap 4.16.16

- `test/input/html/`: Update html test input files to reflect fix in v4.16.10
- Remove `test/input/html/example1-clearly-false-white-swan-simplified-with-links.html` since no related input file.

## argmap 4.16.15

- `mapjs/src/browser/update-connector-text.js`: Fix lint errors without breaking link selection.
- [README.md](../README.md): Fix lint error.

## argmap 4.16.14

- Fix remaining eslint errors manually, except:
- `mapjs/src/browser/update-connector-text.js`: Revert linting changes from v4.16.12 since this broke link selection.

## argmap 4.16.13

- `mapjs/.eslintrc.json`: Update with configuration from newly installed VSCode extension: [ESLint - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint).

## argmap 4.16.12

- `mapjs/src`: Save changes from `npm run lint -- --fix`.
- Save output as `mapjs/lint_errors.txt`

ISSUE: Change in `mapjs/src/browser/update-connector-text.js` broke link selection.

## argmap 4.16.11

- `mapjs/package.json`: Add lint command as script.

## argmap 4.16.10

- `mapjs/webpack.config.js`: Change webpack output file from `bundle.js` to `main.bundle.js` in preparation for optimising bundle.
  - Update dependencies on `bundle.js`

ISSUE: Forgot to update html files in `test/input/html/`.

## argmap 4.16.9

- `mapjs/package.json`: Add `webpack-bundle-analyzer` to look for webpack bundle optimisation opportunities.
- `mapjs/webpack.config.js`: Add comments for using `webpack-bundle-analyzer` during build process.

## argmap 4.16.8

- Upgrade mapjs dependencies to fix security issues:
  - `mapjs/package.json`:
    - New versions.
    - Remove dev dependency `appraise.js`
  - `mapjs/package-lock.json`: Ditto.
  - `mapjs/webpack.config.js`: Update for webpack-server v4.

BUG: Think this bug console error was introduced in this version: `Uncaught ReferenceError: map is not defined webpack-internal:///./src/browser/image-drop-widget.js 9 32 ReferenceError: map is not defined`. Fixed in 4.16.29.

## argmap 4.16.7

- Comment out fengari-web scripts from html templates since focusing on mapjs for now:
  - `pandoc-templates/mapjs/mapjs-quick-json.html`
  - `pandoc-templates/mapjs/mapjs-main-html5.html`

## argmap 4.16.6

- Add `test/output/html` so all html output files in one place.
  - Rename env variable `DIR_HTML_OUTPUT` to `DIR_PUBLIC_OUTPUT`.
  - Update env variable and folder dependencies.

## argmap 4.16.5

- `mapjs/src/argmapjs-utilities.js`: Comment out `mergeObjects()` since no longer needed.
- `mapjs/package.json`: Remove `lodash` dependency since only needed for `mergeObjects()`. May re-introduce instead of `underscore`.

## argmap 4.16.4

- Started debugging multi-line YAML example:
  - `.vscode/launch.json`: Add debug profile for multi-line example.

## argmap 4.16.3

- `test/issues/`: Remove 2 mup files since they now work correctly.

## argmap 4.16.2

- `test/input/big_input.yml`: Last 50% invalid YAML, probably a formatting issue, have removed that section.

## argmap 4.16.1

- `mapjs/src/start.js`:
  - Update `loadMap()` to batch up a paste of loaded map, plus deletes the old one, so that undo/redo can be used to restore old map.
  - Disabled automated submit button after load.
- `mapjs/src/core/content/content.js`: Add comments for how to access the undo/redo history (eventStacks and redoStacks), in case needed for debugging.
- `.vscode/settings.json`: Add spelling.

## argmap 4.16.0

- Add basic yaml load/edit/submit to quick template UI:
  - `pandoc-templates/mapjs/mapjs-quick-json.html`:
    - Add large textarea for yaml load and edit.
    - Add file picker input to load files into text area.
    - Add submit button to update mapjs container with yaml input by calling `submit_yaml()`.
  - `mapjs/src/start.js`: Added `loadMap()` to load JSON into container.
  - `src/client_argmap2mapjs.lua`:
    - Add `submit_yaml()` to read yaml from text area, pass it to `argmap2mapjs`, then send output to mapjs `loadMap()` function, so can now hand edit data as well as open files.
    - Restore change event listener to fileChooser, which reads file into text area.
    - Add click event listener to submit button which calls `submit_yaml()`.
    - Remove call which converted the the yaml data to mapjs format.
    - Customise logger function so console filtering works as expected.

NEW ISSUE: Sometimes getting mapjs error `Uncaught TypeError: Cannot read properties of undefined (reading 'setIdea')`. This stops submit working until reload.

## argmap 4.15.3

- `test/test_scripts/tests.sh`: Add webpack command before test to ensure latest mapjs code being tested.

## argmap 4.15.2

- Add fengari-web source map: `src/js/fengari-web.js.map`
  - Symlinking to it from `mapjs/site/js` but for some reason that's not appearing in git repo.
    - `scripts/install.sh`: Add symlink command.
  - `src/js/fengari-web.js`: Add reference comment to it.
- `.gitignore`: Remove obsolete entries.
  
## argmap 4.15.1

- Fix `selectLink()`, which from v4.13.5 was using deprecated window.event object to identify which container a link was in (because links are not guaranteed to have unique element IDs). Hence this function was not working consistently, and breaking regression test.
  - `mapjs/src/start.js`: Add reference to container element to mapModel during initialisation process.
  - `mapjs/src/core/map-model.js`: Instead of using event to identify the container, use the container element reference.
- `.vscode/settings.json`: Add ignored word.

## argmap 4.15.0

- `src/argmap2mup.lua`:
  - Return `a2m` object so that `parse_claims()` and `template`(mapjs theme) can be called externally.
  - Update `markdown_to_plain` so that it doesn't do anything when run from browser (since that uses `io` object which is not available to fengari-web).
- `src/config_argmap.lua`: Minor formatting fix for consistency.

## argmap 4.14.1

- `test/input/big_input.yml`: Add to test handling large yaml files.

## argmap 4.14.0

- Update argmap scripts to run either server side, as before, or client side, using fengari-web:
  - Currently lua scripts don't have any impact client side, but don't break anything either.
  - `src/js/fengari-web.js`: Runs lua VM in the browser. No access to os or io, or lua modules with c bindings. Hence switch to `tinyyaml` in previous release.
  - `src/argmap2mup.lua`: Check whether client or server side, and set variable `script_context` to `server` or `client` to stop any calls to os or io.
  - `src/client_argmap2mapjs.lua`: Lua script called from web page, temporary solution for setting up env for argmap2mup to run in.
  - `pandoc-templates/mapjs/`: Add fengari-web and argmap2mup-test scripts to both templates.
  - `mapjs/site`: Add symbolic links so `src/`, `lua_modules/`, `test/output` folders and `fengari-web.js` available to web page.
    - `scripts/install.sh`: Add symbolic link creation code.
    - `.gitignore`:
      - Refine so only site/js/bundles.js ignored, not symbolic link to `fengari-web.js`
      - Update so that `mapjs/site/output` symbolic link (which has been present for a long time) is included in repo.

## argmap 4.13.23

- `scripts/bash_aliases_argmap.sh`: Fix calls to lua scripts (e.g. a2m() calling argmap2mup) so they work without shebang directive, since debugging doesn't work when this is present.
- `src/pandoc-argmap.lua`: Do the same, update `pandoc.pipe` calls to use lua as command, and script as the first argument.
- `test/output/example1-clearly-false-white-swan-simplified.tex`: Replace obsolete reference file.

## argmap 4.13.22

- `argmap-4.13.22-9.rockspec`: Update with new tinyyaml module.
- `scripts/luarocks_clean.sh`: Add missing --tree from luarocks calls, so uninstalls apply to local yaml_modules not global.
- Fix small misc things, update comments.

## argmap 4.13.21

- Argmap uses local lua files only:
  - `scripts/argmap.env`: Update env variable `PATH` to check local src folder first, this means lua files will be called from there instead of conda env bin where possible.
  - `scripts/bash_aliases_argmap.sh`: Update all references to lua files to include `.lua` extension so they use the local file rather than the symlinked command without the extension.
  - Keeping symlinks for calling from outside of project, but shouldn't need them within project.

## argmap 4.13.20

- `scripts/argmap.env`: Update `LUA_PATH` and `LUA_CPATH` to check only local paths, not central conda env folder.

## argmap 4.13.19

- Fix argmap config so it works properly when installed in other folders:
  - Removed env variables `LUA_PATH` and `LUA_CPATH` from conda env settings so they can be folder dependent instead:
  - `scripts/argmap.env`:
    - Set both Lua path variables here instead.
  - Update `environment.yml`

## argmap 4.13.18

- `src/config_argmap.lua`: Fix package.cpath reference, which was to invalid argumend conda env path.
  - Think this fixes lyaml install issue introduced around v4.13.15.
    - Presumably rockspec external_dependencies parameter (used to find YAML library) uses CPATH.
    - Though didn't test this, so could have been any commit between v4.13.18 and v4.13.21 which fixed it.

## argmap 4.13.17

- `src/config_argmap.lua`: Remove duplicate entry in `package.path` and split `package.cpath` into two concatenated strings for readability.

## argmap 4.13.16

- Use pure lua yaml module [`tinyyaml`](https://github.com/api7/lua-tinyyaml) instead of c binding [`lyaml`](https://github.com/gvvaughan/lyaml). This will allow it to be run client side when fengari-web used.
  - `src/argmap2mup.lua`: Update to use new tinyyaml and remove terminating `...` from yaml block, which seems to break tinyyaml. (See <https://github.com/api7/lua-tinyyaml/issues/22>)
  - Update `argmap-4.6.1-8.rockspec`
  - `test/`:
    - `input/example1-clearly-false-white-swan-simplified.yml`: Remove terminating `...` from yaml block, which seems to break tinyyaml.
    - `test/output/example1-clearly-false-white-swan-simplified.yml`: Delete since redundant.
  - Add to project dictionary: `.vscode/settings.json`
- `.gitignore`: Remove obsolete directory.

## argmap 4.13.15

- `.vscode/launch.json`: Distinguish duplicate launch profile names.
- ISSUE: Lua dependency lyaml c module broken after reinstall round about now.

## argmap 4.13.14

- Remove obsolete archived input files:
  - `test/input/archived/Example1_ClearlyFalse_WhiteSwan.mup`
  - `test/output/example1-clearly-false-white-swan-simplified.yml`

## argmap 4.13.13

- Add test for argmap2mup with `examples/example-2.yml` (which uses notes):
  - `scripts/argmap.env`: Create env var `INPUT_FILE_YML_NOTES` for this file.
  - `test/test_scripts/tests.sh`: Add argmap2mup test using this variable.

## argmap 4.13.12

- `src/argmap2mup.lua`: Update map uploaded message to show whole MindMup url, not just the GDrive file ID.

## argmap 4.13.11

- `src/argmap2mup.lua`: Fix issue with handling notes created in v4.8.7:
  - Initialise `attr` as {} again, so that no error is thrown when notes are used in the yaml input (e.g. with input `examples/example-2.yml`).
    - Instead, applies `default_to_nil()` to `attr` at end of function.
  - Update some comments.
  - `.vscode/launch.json`: Update to debug `examples/example-2.yml`.

## argmap 4.13.10

- `docs/`: Update screenshots (new connector colours).

## argmap 4.13.9

- `mapjs/src/browser/dom-map-controller.js`:
  - Apply 2 fixes from [garlic0708 mindmup commit](https://github.com/mindmup/mapjs/commit/45ce477c400d5d8a67c86758bc8d0643e2f8828b):
    - Fix stats by initialising as {}
    - Add comments showing how to keep new node even if text isn't edited.

## argmap 4.13.8

- `scripts/bash_aliases_argmap.sh`: Minor `a2mu()` improvement: Report uploaded filename, not input filename.

## argmap 4.13.7

- `.vscode/settings.json`: Add pandoc template argument to Markdown Preview Enhanced extension's pandoc settings.

## argmap 4.13.6

- `src/config_argmap.lua`: Stop os.getenv("LUA_PATH") throwing error when returning nil with Markdown Preview Enhanced VSCode extension.

## argmap 4.13.5

- `mapjs/src/core/map-model.js`: Fix bug with highlighting selected links when 2 containers on page, by properly distinguishing between the containers:
  - Selecting link on one container would remove the selection border from selected link in the other container.
  - Selecting a link in the lower container would select any links with identical element id in the upper container instead.
  (Unfortunately, map element IDs are currently only unique within a container, not on a page as they should be).

ISSUE: Fix used deprecated `window.event` object, which resulted in inconsistent behaviour including devtools recording test. Fixed in v4.16.1 by adding reference to container element to mapModel in `start.js`.

## argmap 4.13.4

- Add test page with 2 different maps: `test/input/markdown/2-maps-swan-donkey.md`.

## argmap 4.13.3

- `mapjs/src/themes/argmap-theme.json`: Change opposing, supporting, node selection / activation and link selection colours for higher contrast (for colour blind users). Opposing much pinker now.
- `test/`: Add input files with thinner opposing lines so easier to compare contrast visibility.

## argmap 4.13.2

- `test/devtools-recordings/`:
  - Add 5 new recordings to test: zooming, add parent to root, edit link, delete grandchild
  - Remove viewport step of existing recordings.
  - `mapjs/scripts/mapjs.env`: Add env variables for recordings.
  - `test/test_scripts/tests.sh`: Add tests for recordings.
    - Only 1 of them works in TestCafe: Add parent to root.

## argmap 4.13.1

- Update vscode workspace dictionary.

## argmap 4.13.0

- `mapjs/src/start.js`:
  - FEATURE CHANGE: Paste dragged mapjs files into container, instead of replacing the old one.
    - Better because it's:
      - Less destructive.
      - Allows undo / redo.
      - Additionally, my implementation happens to stop non-mapjs `.json` files making any change to the map, fixing issue introduced in v4.12.0
    - ISSUE: Only supports the same features as paste, so does not currently support links or themes.
- [mapjs/README.md](../mapjs/README.md): Update to reflect above.

## argmap 4.12.0

- `mapjs/src/start.js`:
  - Fix issue stopping drag and drop `.mup` files into the container, introduced in v4.9.14
  - Update to accept `.json` files too, so now any mapjs file should work.
    - ISSUE: Unfortunately, dragging non-mapjs `.json` files into container replaces map with empty root node.
- Document in [mapjs/README.md](../mapjs/README.md): Can drag and drop `.mup` and `.json` files into the container to display them instead of the current map.

## argmap 4.11.4

- Update screenshots to use latest mapjs appearance:
  - Update docs to use latest screenshots:
    - `test/input/html/example-updated.html`: Update example input html.
      - Update links to it in [README.md](../README.md).
    - Add mapjs example screenshot to [mapjs README](../mapjs/README.md).

## argmap 4.11.3

- `mapjs/site/mapjs-default-styles.css`: Update comments.

## argmap 4.11.2

- `test/output/example1-clearly-false-white-swan-simplified.yml`: Update to reflect new output based on updated input .json file:
  - `test/input/example1-clearly-false-white-swan-simplified.yml`: Update reference input file too.

## argmap 4.11.1

- Fix `test/devtools-recordings`:
  - Fix toolbar id used in `supporting-group` recordings.
  - Remove aria directives from recordings since these are unnecessary.

## argmap 4.11.0

- When dragging images, show border round node it will drop onto:
  - API change:  `mapjs/src/browser/dom-map-controller.js`: Add `stagePositionForPointEvent()` to `domMapController` object so it can be called from `mapjs/src/browser/image-drop-widget.js` to detect droppable node.
  - `mapjs/src/browser/image-drop-widget.js`:
    - Add code for detecting current droppable target and adding 'droppable' class to it.
      - ISSUES: This does not seem to work well for group nodes or second of two containers on page.
    - Add code to remove this class when leaving droppable target.
    - BUG: Broken undefined check (forgot the quotes around undefined). This had unexpected side effects including breaking mup json drag and drop from around v14.16.8
  - `mapjs/src/core/map-model.js`: Add comment re possible improvement.

## argmap 4.10.12

- Add input file for testing: `test/input/html/example1-clearly-false-white-swan-simplified-1mapjs.html`.

## argmap 4.10.11

- `mapjs/site/mapjs-default-styles.css`: Centre align root node text.

## argmap 4.10.10

- `mapjs/site/mapjs-default-styles.css`: Replace non-existent properties ('background-height', 'background-width') for `.mapjs-reorder-bounds` with correct `background-size`.

## argmap 4.10.9

- Fix linting errors, mainly from new VSCode markdown checker:
  - Broken links
  - Missing input file: `test/input/html/example-updated_.html`
  - Dictionary error
  - Bullet point lint warnings.

## argmap 4.10.8

- Minor doc update: [mapjs/README.md](../mapjs/README.md)

## argmap 4.10.7

- `mapjs/src/themes/argmap-theme.json`: Update connection labels' `ratio` and `aboveEnd` parameters (used by `mapjs/src/browser/calc-label-center-point.js`) so labels are positioned better.

## argmap 4.10.6

- Add `test/input/html/example1-clearly-false-white-swan-simplified-2mapjs.html` to input folder for easier testing.
- `mapjs/src/start.js`: Remove comment about bug which has since been fixed.

## argmap 4.10.5

- `mapjs/src/core/map-model.js`: 'Parent reason' now works on root nodes. However:
  - First parent grouping doesn't show up until a parent is added. This is general issue with groupings - they don't display when orphaned.
  - Original root node doesn't stop looking like root node until new parent root node added. Again, this is a separate issue.

## argmap 4.10.4

- `mapjs/src/core/content/content.js`: Fix error thrown when insert parent on root node, by re-applying code from commit 'allow insertIntermediate to add parent(s) to root nodes' (`98059f9ff83a681d13ab764f4b03068766211d2d`).

## argmap 4.10.3

- `mapjs/src/browser/dom-map-controller.js`: Enable right click to bring up context menu when hovering over nodes.

## argmap 4.10.2

- `pandoc-templates/mapjs/mapjs-testcontrols.html`: Capitalise all toolbar buttons' first word for consistency with link edit widget.
  - Update `test/input/html/` files.

## argmap 4.10.1

- `mapjs/site/mapjs-default-styles.css`: Update selected link (purple dashed) outline to 1.5px since 1px invisible in chrome sometimes.

## argmap 4.10.0

- Add image drag and drop:
  - Revert commit eb634329af9af66211bfc07d5f9088acb602734b and merge files
  - Add `mapjs/src/browser/get-data-uri-and-dimensions.js` from commit c16ddf39d8173260366b1e00c182432d4da6cf1a
  - Update mapjs [README.md](../mapjs/README.md) with basic instructions including new drag and drop image functionality.

## argmap 4.9.38

- Move chrome debug profile out of tmp folder into misc folder so settings stay consistent:
  - Set up new env variable for misc folder.
  - Rename chrome debug profile variable to PATH_CHROME_PROFILE_DEBUG and update to new location.
  - Update other .env and script files.
- Update .gitignore

## argmap 4.9.37

- `mapjs/src/start.js`: Add comments for clarity.

## argmap 4.9.36

- `mapjs/src/browser/update-connector-text.js`:
  - Changes calculation of connector text position so it's nearer the parent node. Not entirely successfully: the x position isn't very good because the mapjs-connector ClientRects.left and .right don't seem to relate to the actual boundary of the element. So, this change divides the impact of the new x position calculation by 100.
  - Also renamed a variable for clarity.

## argmap 4.9.35

- `mapjs/src/themes/argmap-theme.json`: Give supporting connector text white background instead of transparent for clarity (now matches opposing).

## argmap 4.9.34

- Increase size of text in both nodes and connectors to 14px.

## argmap 4.9.33

- Highlight selected links so that it's clearer which the linkEditWidget will affect:
  - `mapjs/src/core/map-model.js`: Update `selectLink()` to add `selected-link` class to links when selected (and remove from old link).
    - Also node IDs can contain dots ('.')
      e.g. `test/input/html/example2-clearly-false-white-swan-v3.html`
    so rewrite ID . with _, consistent with how they appear in HTML.  
  - `mapjs/site/mapjs-default-styles.css`: Add outline styling to .map-js element child of `.selected-link`.
  - To simplify testing links, add:
    - `test/input/mapjs-json/example1-clearly-false-white-swan-simplified-with-links.json`
    - `test/input/html/example1-clearly-false-white-swan-simplified-with-links.html`

  ISSUE: Bug with highlighting selected links when 2 containers on page, fixed in v4.13.5

## argmap 4.9.32

- Tidy comments and format code.

## argmap 4.9.31

- `mapjs/src/themes/argmap-theme.json`: Make white backgrounds transparent.

## argmap 4.9.30

- `mapjs/src/themes/argmap-theme.json`: Make outline for selected and activated group nodes blue like regular nodes, rather than red / green.

## argmap 4.9.29

- `mapjs/site/mapjs-default-styles.css`: Make node drag/drop clearer:
  - Make red border wider and dotted.
  - Reduce dragged node opacity.
  - Change mouse cursor when dragging.

## argmap 4.9.28

- `mapjs/site/mapjs-default-styles.css`: Separate out css for text (non-group) nodes using `.mapjs-node:not(.attr_group)`, so that group nodes don't have a fill colour.

## argmap 4.9.27

- `mapjs/site/mapjs-default-styles.css`: Give nodes a faint grey background.

## argmap 4.9.26

- `mapjs/site/mapjs-default-styles.css`: Make root nodes more distinctive.

## argmap 4.9.25

- `mapjs/site/mapjs-default-styles.css`: Make mouse into pointing finger (`pointer`) when hovering over node.

## argmap 4.9.24

- Make default node font larger and bolder:
  - `mapjs/site/mapjs-default-styles.css`:
    - Combine separated `.mapjs-node` settings.
    - Update font settings to be larger and bolder, using `!important`.
  - `mapjs/src/themes/argmap-theme.json`: Update node font weight and size, although this doesn't seem to affect map because a different style is being set somewhere.

## argmap 4.9.23

- `mapjs/src/start.js`: Set `mapjs/src/themes/argmap-theme.json` to be default theme instead of idea.theme (mapjs file theme), so easier to change theme settings in future.

## argmap 4.9.22

- `mapjs/site/mapjs-default-styles.css`: Remove black outline that appears on page load, by adding `outline: none` for `.container_argmapjs`.

## argmap 4.9.21

- `mapjs/src/browser/update-stage.js`: Update transform3d and transform y value to always be 30% instead of using offsetY based on height. This aligns top of map higher up on page.
- `mapjs/site/mapjs-default-styles.css`:
  - Comment out css transform overrides for `div[data-mapjs-role=stage]`. This also fixes broken zoom in/out.
  - Increase `.mapjs_control` min-height so that link-edit-widget appearance doesn't shift map down by a few pixels (unless control wraps an extra line).
- `mapjs/src/browser/dom-map-widget.js`: Add comments about controlling svg layout.

## argmap 4.9.20

- Remove legacy screenshots:
  - `docs/mapjs-example2-white-swan-complex-argmapjs-argmap-theme.png`
  - `docs/mapjs-example2-white-swan-complex-argmapjs-default-theme.png`

## argmap 4.9.19

- Fix `Arrow` button in `linkEditWidget`. Was based on button active state, which seems weird and didn't work. Now just toggles between `to` and `false`.

## argmap 4.9.18

- Add devtools recordings to test add supporting group button for 2 different pages.

## argmap 4.9.17

- Fix template bug with container ID which broke add parent and supporting/opposing groups, and update templates.

## argmap 4.9.16

- Fix css to improve map positioning.
- `mapjs/src/themes/mapjs-argument-mapping.json`: Rename for clarity.

## argmap 4.9.15

- Fix css so maps are positioned better and toolbar is placed at higher z-index so buttons aren't blocked.

## argmap 4.9.14

- Update code and html generation to handle multiple containers on a page properly. FIX #22.
- ISSUE: This introduced a bug with dragging and dropping `.mup` files into the container to display them. Fixed in 4.12.0

## argmap 4.9.13

- Add functions for theme switching and merging:
  - `mapjs/src/start.js`
  - `mapjs/src/argmapjs-utilities.js`
- Add lodash as dependency.
- Update themes, make source files `.json`.

## argmap 4.9.12

- `mapjs/webpack.config.js`: Change `devtool: 'cheap-module-eval-source-map'`for faster build time (not for production use).

## argmap 4.9.11

- `docs/`:
  - Add screenshots using argmap theme:  
    - `mapjs-example-brunellus-argmap-theme.png`, `docs/mapjs-in-html-example.png`: Brunellus example, updated in [README.md](../README.md).
      - Add `test/input/html/example-updated.html` for example screenshots to link to.
    - `example2-white-swan-complex-argmapjs-argmap-theme.png`: better screenshot of mapjs argument, using argument map theme.
      - Rename default theme screenshot for clarity.

## argmap 4.9.10

- `scripts/bash_aliases_argmap.sh`: Fix `open-debug()` bugs with handling default and relative paths to workspace.

## argmap 4.9.9

- `.vscode/launch.json`: Fix mapjs debug source mapping (webRoot) so breakpoints work properly.
  - `.vscode/settings.json`: Set variable for mapjs folder, used in webRoot path.

## argmap 4.9.8

- `scripts/bash_aliases_mapjs.sh`: Add alias `pmj` to run webpack pack on mapjs.

## argmap 4.9.7

- [mapjs/README.md](../mapjs/README.md): Update mapjs keyboard shortcut section.

## argmap 4.9.6

- mapjs/src/browser/dom-map-widget.js`: Fix zoom in/out keyboard shortcuts:
  - Now using keyCode, instead of keyIdentifier which didn't work. However, keyCode is deprecated: ISSUE s6mike/mapjs#3
  - Add 2 missing key codes.

## argmap 4.9.5

- `test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp`: Updated chrome crash dumps dir to be `/tmp`, rather than inside project directory.

## argmap 4.9.4

- `mapjs/src/browser/dom-map-widget.js`: Restore missing tabindex attribute to container, which is needed for divs to get focus (see [tabindex - HTML: HyperText Markup Language | MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/tabindex)). This was breaking keyboard shortcuts after clicking on blank part of the container (svg canvas), an issue introduced in v4.8.17.
- Add `tabindex` to lua code which generates html so not dependent on js code alone:
  - `src/pandoc-argmap.lua`
  - `pandoc-templates/mapjs/mapjs-map.html`
- Update notes on `test/test_scripts/tests.sh`.

## argmap 4.9.3

- Add `test/input/html/example2-clearly-false-white-swan-v3.mup.html` (full white swan argument) to repo for testing etc.

## argmap 4.9.2

- `scripts/bash_aliases_argmap.sh`: Update `j2hf()` to remove `.mup` suffixes as well as `.json`

## argmap 4.9.1

- `mapjs/src/browser/dom-map-widget.js`: Commented out lines which automatically set container css property `overlay` to `auto` or `hidden` after interactions, so that my preferred css setting of `visible` is not changed. This ensures that full map is always visible.

## argmap 4.9.0

- `scripts/bash_aliases_argmap.sh`:
  - Add argmap specific `open-debug()`, which can open from abs or relative path to either site or test folder, plus default to simpler html page.
  - Update `j2hf()` for same input file flexibility and default html page.

## argmap 4.8.22

- `test/input/`:
  - Remove unnecessary json file.
  - Re-organise contents into sub-folders.
  - Rename some for consistency.
- `mapjs/site/index.html`: Update to symbolic link to point to simpler html page.
- `scripts/argmap.env`: Update above input file paths including simpler `index.html`
- `scripts/bash_aliases_mapjs.sh`: Update aliases for opening output files to reflect updated input files.
- `test/devtools-recordings`: Update 3 recordings broken by `index.html` having different toolbar id.

## argmap 4.8.21

- `test/devtools-recordings/argmap-keys-undo-redo.json`: Add (currently failing) test for issue where undo/redo keys don't work unless a node has focus.
  - Rename `test/devtools-recordings/argmap-button-undo-redo.json` to clearly distinguish from above.
  - `mapjs/scripts/mapjs.env`: Add/update variables for above scripts.
  - `test/test_scripts/tests.sh`: Add above test, though comment out for now to stop pre-commit hook failing.
- `test/test_scripts/mapjs_bisect_supporting_group.sh`: Remove since obsolete.

## argmap 4.8.20

- `mapjs/site/input/mapjs-json/example1-clearly-false-white-swan-simplified.json`: Update with fixed version.
- `mapjs/src/core/content/content.js`: Comment out debugger statement in `handleRangeError()` since issue seems to be resolved now.

## argmap 4.8.19

- `scripts/bash_aliases_argmap.sh`: Update `j2hf()` to open browser with debug port open, to simplify debugging.
- `mapjs/src/core/theme/theme.js`: Reformat comment manually and auto-format code.

## argmap 4.8.18

- Update `test/input/example1-clearly-false-white-swan-simplified-1mapjs.html` with css changes.
  - Fix some inconsistent filenames in `test/input`, missed in v4.8.14.
    - Update path variables in `scripts/argmap.env`
    - Update index file symbolic link: `mapjs/site/index.html`

## argmap 4.8.17

- Consolidate css styles and override mapjs-container's overflow: auto style for easier viewing of large maps:
  - `mapjs/src/browser/dom-map-widget.js`: Remove line adding overflow: auto to mapjs-container's style.
    - ISSUE #2 introduced: clicking in container restores `overflow: auto` to `element.style`: Must be another piece of code updating it again.
    - ISSUE this line also assigned a tab index to the container, which is necessary for sequential keyboard navigation. This stopped keyboard shortcuts working after clicking on blank part of container (svg canvas). Fixed in v4.9.4
  - `mapjs/site/mapjs-default-styles.css`: Add css from `pandoc-templates/mapjs/mapjs-inline-styles.css` (embedded directly into html).
    - Remove `pandoc-templates/mapjs/mapjs-inline-styles.css` and references in template files:
      - `pandoc-templates/mapjs/mapjs-quick-json.html`
      - `pandoc-templates/mapjs/mapjs-main-html5.html`

## argmap 4.8.16

- `test/input/mapjs-json/example2-clearly-false-white-swan-v3.mup`: Add new version of example 2, with better inline objections, removing older ones.

## argmap 4.8.15

- `.gitignore`: Add `tmp/` folders. e.g. `mapjs/tmp`.

## argmap 4.8.14

- Add fixed, renamed and prettified test files to `examples/`,`test/input/` and `test/output/` e.g. `test/input/mapjs-json/example1-clearly-false-whiteswan-simplified-1mapjs-argmap2.json`.
- `test/input/mapjs-json/example1-simple-replicated-in-mapjs-legacy.json`: Add a duplicate of my simple example in legacy mapjs for comparison purposes.
- Add `test/input/mapjs-json/example2-clearly-false-white-swan-minus-inline-objections.mup`, created in mindmup.
  - Add `docs/example2-white-swan-complex-argmapjs-4_8_13.png`: screenshot of above file viewed using mapjs.
- Move legacy mapjs index.html to `test/input/legacy-mapjs-example-map.html` since input folder more logical location.
- Update symbolic link: `mapjs/site/index.html`
  - Update env variables in these files to simplify symbolic link maintenance when file names change:
    - `mapjs/scripts/mapjs.env`
    - `scripts/install.sh`
- Update with renamed file paths: `scripts/argmap.env`, `scripts/bash_aliases_argmap.sh`, `.vscode/launch.json`, `test/input/example1-clearlyfalse-white-swan-simplified-1mapjs.html` etc.
- `test/test_scripts/tests.sh`: Log test results for reference:
  - `scripts/argmap.env`: Add env variable for test log path.
- Add comments to some script files.

## argmap 4.8.13

Files created from argmap2mup now work with MindMup. Fix #11.

- `src/argmap2mup.lua`:
  - Fix empty `"attr": {"parentConnector":` so it's omitted instead of having value [], which breaks mapjs logic.
    - Delete output `.json`/`.mup` files containing `"parentConnector": []`.
  - Change `default_to_nil()` to be local function (better practice).
- [README.md](../README.md): Update to reflect fix.

## argmap 4.8.12

- `scripts/bash_aliases_argmap.sh`: Fix `j2hf()` to work with files from input folder too, though now path argument has to be in `mapjs/site` folder.

## argmap 4.8.11

- `test/input/mapjs-json/legacy-mapjs-example-map.json`: Add legacy mapjs `example-map.json` to `mapjs-json` input folder.
- `test/input/mapjs-json/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs_argmap2.json`: pretty print content.

## argmap 4.8.10

- `.vscode/launch.json`: Fix debugging launch profile for [Lua Debug - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug) since [Local Lua Debugger - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode) stopped working.
- Add lua local path fix but leave commented out since still not working properly:
  - `.vscode/settings.json`
  - `src/config_argmap.lua`

## argmap 4.8.9

- Still getting issues with render test #5 (expect script), looks like it's running before server ready, so:
  - `test/test_scripts/tests.sh`:
    - Swap test #5 with #6 (open mapjs file) because this is a quick visual test, so can just refresh the page once server is up to check it.
    - Add extra diagnostic message in case of failure.
    - Add comments with notes about alternative solutions.
  - `scripts/bash_aliases_mapjs.sh`: Add diagnostic message.
  - `test/test_scripts/headless_chrome_repl_mapjs_is_rendered.exp`: Add comment re debugging.

## argmap 4.8.8

- Fix errors caused by missing output files:
  - `scripts/bash_aliases_argmap.sh`: Add `mkdir --parent` before any file generation.
  - `src/pandoc-argmap.lua`: Add `ensure_directory()` to do same.
  - Add error messages for when the directory creation fails.
  - Add `test/input/mapjs-json/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs_argmap2.json` to ensure rendering test 5 passes.
    - Update `test/input/Example1-ClearlyFalse-WhiteSwan-simplified-1mapjs.html` to reference this file.
  - `test/output/Example1_ClearlyFalse_WhiteSwan_simplified.mup`: Update example output file with fix.
- `test/input/Example1_ClearlyFalse_WhiteSwan_simplified_1mapjs.md`: minor comment updates.
- `.gitignore`: Update to ensure `output-bak` ignored when testing missing folder.

## argmap 4.8.7

- Fix empty ideas and attr having value [] instead of {}, which breaks mapjs logic:
  - `src/argmap2mup.lua`:
    - Add Default_to_nil() so that empty ideas variable can be omitted instead of being [].
      - 2 functions return this function output, instead of returning ideas value directly.
    - attr initialised to nil instead of {} so that it will be omitted if left empty.
      - ISSUE: This fix causes an error to be thrown when notes are used in the yaml input (e.g. with input `examples/example-2.yml`).
        - Fixed in v4.13.11
    - Add check for empty argmap.yml input to stop crash.
- `src/config_argmap.lua`:
  - Add 'Local Lua' debugger path to `package.path` (LUA_CPATH) in case it's missing.

## argmap 4.8.6

- `mapjs/src/core/content/content.js`: Add handleRangeError() using code from 4.8.2, with additional debugger statement.
  - Call it from try catch in same 2 functions: `isRootNode()` and `removeSubIdea()`, plus 1 additional: `findChildRankById()`.

## argmap 4.8.5

- `mapjs/src/core/content/content.js`: Create deleteIfEmptyGroup() to delete group (supporting/opposing node) if it's empty, using code from fix in 4.8.1
  - Update above fix to use this function instead.
  - Call this function after making a child node into a root, so that dangling group node not left in idea model.

## argmap 4.8.4

- Check for undefined variables to avoid crash:
  - `mapjs/src/core/map-model.js`
  - `mapjs/src/browser/dom-map-widget.js`

## argmap 4.8.3

- `mapjs/src/core/content/content.js`: Fix first child nodes not being deletable. Because rank was 0 which is falsy value, leading to failing test during removeSubIdea(). Changed to an explicit test for missing values.

## argmap 4.8.2

- Catch RangeErrors due to searching map for ideas which don't exist:
  - `mapjs/src/core/content/content.js`: In two functions: `isRootNode()` and `removeSubIdea()`.
    - `removeSubIdea()`:
      - Also move search for id to start of function to save time if id not found.
      - Issue caused by 4.8.1 fix, which also ends up being triggered when idea has already been deleted, leading to a search for a deleted idea.
- Undefined has no property `ideas` also thrown in `mapjs/src/argmapjs-utilities.js`, fixed with conventional check.

## argmap 4.8.1

- Fix idea model not being updated when supporting/opposing group deleted because it is empty:
  - `mapjs/src/core/content/content.js`: Delete empty group from idea model without breaking undo/redo.
  - `mapjs/src/browser/dom-map-controller.js`: Add comment about solution.

## argmap 4.8.0

- `mapjs/src/core/map-model.js`: For debugging, call new utility function idea_pp() each time map layout is updated.
  - `mapjs/src/argmapjs-utilities.js`: Add utility functions for pretty printing mapjs idea object for debugging purposes.
  - `mapjs/src/npm-main.js`: Add utility script to webpack.

## argmap 4.7.24

- `mapjs/src/core/content/content.js`: Fix `contentIdea.containsDirectChild` error where "Cannot read properties of undefined (setting 'id')" when dragging nodes in some circumstances.
- Add comments to code which might trigger similar errors.

## argmap 4.7.23

- `mapjs/src/core/map-model.js`: Fix "Cannot read properties of undefined (setting 'y')" when dragging nodes in some circumstances.
  - Issue was that first sibling of node was `undefined`, and therefore can't have y value. Have fixed by checking for this, but better solution may be to avoid undefined nodes/siblings.

## argmap 4.7.22

- Add regression test:
  - `test/devtools-recordings/argmap-edit-first-child.json`: Add devtools recording.
  - `mapjs/scripts/mapjs.env`: Add path variable to recording.
  - `test/test_scripts/tests.sh`: Add regression test to call recording.

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
    `__pack_mapjs()`: Remove env variable argument since specific `.json` files no longer requested during webpack build process.
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

  - Merge with local custom branch of repo [`s6mike/mapjs-webpack-example at custom`](https://github.com/s6mike/mapjs-webpack-example/tree/custom). See [README.md](../README.md#displaying-argmaps-with-mapjs) for more details.
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
  
    - See [CHANGELOG-mapjs.md](../mapjs/docs/CHANGELOG-mapjs.md) for more details.
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

- [CONTRIBUTIONS.md](../CONTRIBUTING.md): Update for clarity.

## argmap 3.1.10

- [CONTRIBUTIONS.md](../CONTRIBUTING.md): Update for clarity.

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
  - Add reference to issue 11: generated .mup files don't always work on MindMup, but can be used with legacy mindmup.
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

- Update [README](../README.md), [license](../LICENSE).
- Add this CHANGELOG.md file.

## argmap 1.0.0

Original <https://github.com/dsanson/argmap>

-------------------------

Uses [Semantic Versioning 2.0.0](https://semver.org/) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Note that test files, and bash script functions beginning with __ are not considered part of a public API, and therefore updates may change them without warning.

Though documentation is not yet precise and comprehensive! Lua code is well documented, but my scripts still need to be properly documented.
