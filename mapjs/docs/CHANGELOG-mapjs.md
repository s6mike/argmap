# Mapjs Project Change Log

## mapjs 4.0.0

- Align with argmap changes (v4.3.0): BREAKING
  - Restructure folder so inputs and outputs logically separated:
    - `mapjs/test/`:
    - Move website dependencies to `site/`:
      - Move `/mapjs-default-styles.css`
        - `mapjs/scripts/mapjs.env`:
          - Update env variables for css path.
          - Add variables for other paths including devtools recordings.
      - Move all svg files to `site/svg/`.
    - Move js source files to `src/`:
      - Move `theme.js` and `themes/`.
        - `mapjs/src/start.js`:
          - Update reference to `theme.js`.
          - Also change console.log to console.error for catching JSON load errors.
    - `mapjs/webpack.config.js`: Create bundle.js in `site/js/` instead.
  - Move `test/start.js` to `src/start.js` since it's a source file.
  - `package.json`: Add  "type": "commonjs".
  - Remove references to `src/example-map.json` from `src/start.js`
  - Delete since no longer needed:
    - `test/example-map.json`
    - `mapjs/test/index.html`
- Using VSCode defaults for file formatting: many whitespace changes.

## mapjs 3.3.22

- `src/core/content/content.js`: Fix bug causing error when adding node's first child.
  - This is because this code used to add a new child node `parentIdea.ideas[rank] = subIdea` needs to have rank 0 with new arrays, but was being given rank 0, corrupting array structure.
  - This code is used instead of push because it needs to work with both arrays and associative arrays.

## mapjs 3.3.21

- Fix `src/browser/link-edit-widget.js` so that widget correctly shows when links are dashed, and can be changed to solid lines again, by using line style val, rather than text.

## mapjs 3.3.20

- Add jasmine test outputs to `docs/` folder.

## mapjs 3.3.19

- Edit Link Menu/Widget:
  - `src/browser/link-edit-widget.js`:
    - Fix Line Style picklist.
    - Not visible on initial page load.
    - Does not disappear after mouse over.
  - `src/core/content/content.js`: New links are red, not grey.
  - `test/example-map.json`: Change link colour from '#FF0000' to 'red' so that editLink color picklist value set correctly when selecting link.
  - `test/index.html`: Update `#testcontrols` style so editLink widget/menu not partially hidden.
- [README.md](../README.md): Add mouse click related keyboard shortcuts.

## mapjs 3.3.18

- Fix add link button.

## mapjs 3.3.17

- `src/browser/link-edit-widget.js`: Fix error message when clicking delete link button when no link selected.

## mapjs 3.3.16

- Move environment variables from `scripts/mapjs.env` to external file to simplify git bisect process.

## mapjs 3.3.15

- Enable cut/copy/paste:
  - Undo changes made in commit 'remove internal clipboard, to be replaced with browser clipboard actions' (925dc863d260f2d02c65f490617ebd328be8553).
  - [README.md](../README.md): Add keyboard shortcuts for cut/copy/paste.

## mapjs 3.3.14

- `src/browser/dom-map-widget.js`:
  - Add missing keyboard shortcuts (hotkeyEventHandlers) for zoom in/out/reset, from commit 'connector removed, node removed' (75d00a37c585a0c564ff30b493078db80bc6b40e).
    - Add comment for copy/cut/paste, since functions have since been removed from codebase.
    - [README.md](../README.md): Add keyboard shortcuts for zoom.

## mapjs 3.3.13

- [README.md](../README.md):
  - Add table listing keyboard shortcuts.
  - Fix lint issues (from [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)).

## mapjs 3.3.12

- `src/browser/dom-map-widget.js`:
  - Fix undo/redo keyboard shortcuts, removed in commit 'move undo/redo hotkeys to menus' (9fe20371f6f64051f043f546269227103935abed).

## mapjs 3.3.11

- `scripts/mapjs.env`:
  - Add `PATH_REPLAY_SCRIPT_BUTTON_UNDO_REDO` and `PATH_REPLAY_SCRIPT_KEYS_UNDO_REDO` for new devtools recording.
  - Update diff file name in variable.
  - Update destination folder for expect path variable.

## mapjs 3.3.10

- Align with argmap changes.

## mapjs 3.3.9

- `src/core/map-model.js`: Fix left click on node to select (introduced in commit 'moved addLinkMode out of mapModel' 354071624edb6c257441fcdfcb3f11ab92ad395e).
  - Relevant function `clickNode` triggered by `mouseup`: `button` value wasn't used, so test `which` value instead.

## mapjs 3.3.8

- Merge fixes from stash 'All mapjs fixes up to toolbar': just a settings.json with bash terminal init file.
- Add 'scripts/mapjs.env' to hold new environment variables: PATH_LOG_FILE_EXPECT, PATH_REPLAY_SCRIPT, PATH_REPLAY_SCRIPT_ADD_IDEA, PATH_BISECT_PATCH_FILE

## mapjs 3.3.7

- `docs/CHANGELOG-mapjs.md`: Clean up history.

## mapjs 3.3.6

- Version 3.4.0 because latest mapjs tag is 3.3.6
- Add this Change Log file.
- Add cumulative mapjs bugfixes:
  - Fix add parent reason issue.
  - `test/start.js`: Errors sent to console.error, rather than alert which was incredibly annoying!
  - Fix toolbar buttons by restoring `src/browser/map-toolbar-widget` related code which was removed in commit 'initial jquery 3 migration' (`b2768ac`).
  - `src/core/content/content.js`: Fix reject call syntax which caused unrecognised function '_' error.
- `package.json`:
  - Add TestCafe module for automated testing using chrome devtools recordings.
  - Add alias script keys to align with npm lifecycle as described in: <https://docs.npmjs.com/cli/v8/using-npm/scripts>
- Update .gitignore
- Add `package-lock.json` to repo.

## mapjs 3.3.5

- Fork of [mindmup/mapjs](https://github.com/mindmup/mapjs)

----------------

Uses [Semantic Versioning 2.0.0](https://semver.org/) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
