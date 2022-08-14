# Restructure for v4

- [x] break source into core and widgets
- [x] move specs for core into plain jasmine
- [ ] review dependencies and minimise where possible
  - [ ] underscore
  - [ ] jquery (move away from widgets for sharing code)
- [x] include layout and model as part of core
- [ ] figure out how to publish a separate core module
  - [ ] figure out how to deal with dependencies only for core (eg convex-hull)
- [x] remove DOMRender
- [ ] break down dom-map-view into separate files
- [ ] break down dom-map-view-spec into separate files
- [ ] remove editing widgets and move to @mindmup
  - [ ] move image drop widget and image insert controller to @mindmup
  - [ ] move dom-map-widget
  - [ ] move mapmodel editing methods
  - [ ] delete map-toolbar-widget and move to model actions in @mindmup
  - [ ] check if node-resize-widget can move to @mindmup
  - [ ] move link-edit-widget
  - [ ] check theme css widget
- [ ] review all files and break into individual function files (eg hammer-draggable)
- [ ] investigate if canUseData for connectors/links can be replaced with just theme changed? (is that the only case?)
- [ ] move theme updating directly to domMapController listening on mapModel, instead of the widget intermediating

# discuss with dave

- [+] layout-geometry:257 console log -> throw?
- `npm run sourcemap testem/compiled/browser/dom-map-view-spec.js.js:20811:44`
- mapModel.layoutCalculator dependency

# write specs for files without currently

- [ ] core/theme/color-parser
- [ ] browser/place-caret-at-end
- [ ] browser/queue-fade-in
- [ ] browser/queue-fade-out
- [ ] browser/select-all
- [ ] core/util/connector-key
- [ ] core/util/link-key
- [ ] browser/create-connector
- [ ] browser/create-link
- [ ] browser/find-line
- [ ] browser/create-reorder-margin


# propagate to mindmup

- theme css widget changes
- dommapcontroller init
- mapmodel init
- dom map widget init
