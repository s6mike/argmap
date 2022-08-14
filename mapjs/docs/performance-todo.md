* [ ] dimension calculator to use layout similar to mapsvg; don't read overall size then remove image, use functions from layout to calculate size with image depending on metadata
* [ ] alternatively: rewrite dimension calculator to use canvas, then don't calculate via DOM at all
* [ ] cache layout outside DOM
* [ ] initial map load to use a single dom update (eg read from string)
* [ ] remove jquery from critical path on updating node/connectors
* [ ] initial calculation for dom layout
* [ ] deltas/update calculation for dom layout

====

## Caching solutions

* inside JQuery Data
  - con: requires a node - can't be warmed up on map load
  - con: not good for collapse/uncollapse
  - con: jquery
  - pro: automatically cleaned up when a node is removed
* outside dom
  * pro: can be warmed up on map load
  * indexed to ID
    - pro: automatically cleaned up
    - pro: useful for collapse/uncollapse of large groups of nodes
  * indexed by metadata
    - pro: good if lots of nodes are similar
    - con:  as it's not automatically cleaned up (we need to do cache purging somehow)

## Dimension calculator options

Constraint: we don't have access to fonts, browser chooses the font...

options:

1. Use a shadow DOM element to get the overall size
- con: slow
- pro: we use browser text wrapping
  - it matches the DOM editor perfectly
  - it will work for lots of languages
- con: different text wrapping used on exports and screen
- con: circular dep between updateNodeContent and dimension provider, so we can't strip JQuery out of updateNodeContent and do it async...

2. Use canvas getFontMetrics method
- pro: significantly faster as no DOM access needed
- pro: we can use 99% mapjs layout designed for mapsvg... all we need to do is set up a new text engine
- con: we need to use our own text wrapping, which might not match browser 100%
- pro: same text wrapping alg used for exports and screen

3. use a shadow DOM element just to extract the text size, build the up the rest from the theme
- pro: matches text wrapping in browser
- pro: we can reuse the whole pipeline for layout from theme...
- pro: removes the circular dependency between updateNodeContent and dimension provider, letting us optimise the updateNodeContent


====

- currently, a map with 800 nodes takes about 12 secs to load
- currently, small updates to a large map take a 10 secs to execute

- updates should take < 2-3s on a huge map

