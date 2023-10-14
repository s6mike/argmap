# Mapjs Argview Project Change Log

## mapjs 0.3.3

- `netlify.toml`: Update redirect from / to point directly to desired html page, instead of the `output/html/index.html` copy of it.
  - Delete redundant `output/html/index.html` now redirect doesn't use it.

## mapjs 0.3.2

- `.vscode/settings.json`: Add words to dictionary.

## mapjs 0.3.1

- [README.md](README.md): Move netlify deployment badge.

## mapjs 0.3.0 BREAKING

- `output/html/`:
  - Add simplified white swan argmap: `example1-clearly-false-white-swan-simplified.html`
    - `output/mapjs-json/example1-clearly-false-white-swan-simplified.json`: Add json data for above simplified argmap.
  - `index.html`: Replace complex white swan argmap with above simplified version, because it's more mobile friendly than complex argmap. BREAKING
  - `output/html/example2-clearly-false-white-swan-v3.html`: Add complex white swan as its own file.

BREAKING index.html shows different map.

## mapjs 0.2.2

- [README.md](README.md): Add link to netlify deployed website.

## mapjs 0.2.1

- [README.md](README.md): Add netlify deploy status badge.

## mapjs 0.2.0

- `netlify.toml`: Add redirect from `index.html` to `output/html/index.html`.

## mapjs 0.1.0

- Generated from [s6mike/argmap](https://github.com/s6mike/argmap):
  - Using the latest commit, from the branch `21-argmapjs-cli`.
  - Built with webpack in production mode.
  - Using the mapjs file `public/output/mapjs-json/example2-clearly-false-white-swan-v3.json`, plus associated html file renamed as index.html
  - With the minimum required files copied to a new folder, along with:
    - a new `README.md`, adapted from the mapjs README
    - LICENSE and LICENSE.spdx

----------------

Uses [Semantic Versioning 2.0.0](https://semver.org/) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)

Copyright 2022 Michael Hayes and the mapjs contributors
SPDX-License-Identifier: MIT
