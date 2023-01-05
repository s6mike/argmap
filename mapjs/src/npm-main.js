/*global module, require */

require('./browser/dom-map-widget');
require('./browser/map-toolbar-widget');
require('./browser/link-edit-widget');
require('./browser/image-drop-widget');

module.exports = {
	MemoryClipboard: require('./core/clipboard'),
	MapModel: require('./core/map-model'),
	ImageInsertController: require('./browser/image-insert-controller'),
	content: require('./core/content/content'),
	observable: require('./core/util/observable'),
	DomMapController: require('./browser/dom-map-controller'),
	MapToolbarWidget: require('./browser/map-toolbar-widget.js'),
	ThemeProcessor: require('./core/theme/theme-processor'),
	Theme: require('./core/theme/theme'),
	defaultTheme: require('./core/theme/default-theme'),
	formatNoteToHtml: require('./core/content/format-note-to-html'),
	version: 4
};

/* Copyright 2013 Damjan Vujnovic, David de Florinier, Gojko Adzic; 2022 Michael Hayes; and the mapjs contributors
	 SPDX - License - Identifier: MIT */