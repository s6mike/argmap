---
title: Example 1.2 - All swans are white.
template: pandoc-templates/mapjs/mapjs-main-html5.html
argmaps: true
# TODO: These might be better in a defaults file:
#   https://workflowy.com/#/ee624e71f40c
# css: test/mapjs-default-styles.css
# mapjs-output-js: test/bundle.js
# lua-filter: "$WORKSPACE/src/pandoc-argmap.lua"
# data-dir: "$PANDOC_DATA_DIR"
---

This is a simplified version of the White Swan argument in mapjs format:

```{#argmap1 .argmap .yml name="Example 1: All swans are white." to="js"}
"Map 1: All swans are white.":
  r1:
    "Every swan I've ever seen is white.": []
    "These swans are representative of all swans.": []
  o2:
    "Not all swans are white.": []
```

And here it is again:

```{#argmap2 .argmap .yml name="Example 2 (dup): All swans are white." to="js"}
"Map 2: All swans are white.":
  r1:
    "Every swan I've ever seen is white.": []
    "These swans are representative of all swans.": []
  o2:
    "Not all swans are white.": []
```
