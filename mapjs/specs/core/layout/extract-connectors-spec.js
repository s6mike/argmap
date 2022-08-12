/*global describe, it, require, expect, beforeEach*/
const _ = require('underscore'),
	extractConnectors = require('../../../src/core/layout/extract-connectors');
describe('extractConnectors', function () {
	'use strict';
	const makeConnector = (obj) => _.extend({type: 'connector'}, obj);
	let visibleNodes, idea;
	beforeEach(function () {
		idea = {
			id: 'root',
			ideas: {
				1: {
					title: 'parent',
					id: 1,
					ideas: {
						5: {
							title: 'second child',
							id: 12,
							ideas: { 1: { id: 112, title: 'XYZ' } }
						},
						4: {
							title: 'child',
							id: 11,
							ideas: { 1: { id: 111, title: 'XYZ' } }
						}
					}
				}
			}
		};

		visibleNodes = {
			1: {},
			12: {},
			112: {},
			11: {},
			111: {}
		};
	});
	it('creates an object indexed by child ID with from-to connector information', function () {
		const result = extractConnectors(idea, visibleNodes);
		expect(result).toEqual({
			11: makeConnector({ from: 1, to: 11 }),
			12: makeConnector({ from: 1, to: 12 }),
			112: makeConnector({ from: 12, to: 112 }),
			111: makeConnector({ from: 11, to: 111 })
		});
	});
	it('should not include connector when child node is not visible', function () {
		delete visibleNodes[12];
		delete visibleNodes[111];
		expect(extractConnectors(idea, visibleNodes)).toEqual({
			11: makeConnector({ from: 1, to: 11 })
		});
	});
	describe('parentConnector handling', function () {
		beforeEach(function () {
			visibleNodes[12].attr = {parentConnector: {great: true}};
		});

		it('adds parentConnector attribute properties to the connector attributes if the theme is not set', function () {
			const result = extractConnectors(idea, visibleNodes);
			expect(result[12]).toEqual(makeConnector({
				from: 1,
				to: 12,
				attr: {great: true}
			}));
		});
		it('adds parentConnector if the theme is set and does not have a connectorEditingContext', function () {
			const result = extractConnectors(idea, visibleNodes, {connectorEditingContext: false});
			expect(result[12]).toEqual(makeConnector({
				from: 1,
				to: 12,
				attr: {great: true}
			}));
		});
		it('adds parentConnector if the theme is set and has connectorEditingContext with allowed values', function () {
			const result = extractConnectors(idea, visibleNodes, {connectorEditingContext: {allowed: ['great']}});
			expect(result[12]).toEqual(makeConnector({
				connectorEditingContext: {
					allowed: ['great']
				},
				from: 1,
				to: 12,
				attr: {great: true}
			}));
		});
		it('ignores parentConnector properties when the theme blocks overrides', function () {
			const result = extractConnectors(idea, visibleNodes, {connectorEditingContext: {allowed: []}});
			expect(result[12]).toEqual(makeConnector({
				from: 1,
				to: 12
			}));
		});
		it('clones the parent connnector so changes to node can be detected', function () {
			const result = extractConnectors(idea, visibleNodes);
			visibleNodes[12].attr.parentConnector.great = false;
			expect(result[12].attr.great).toEqual(true);
		});
	});
});
