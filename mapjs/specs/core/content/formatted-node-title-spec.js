/*global require, describe, it, expect*/
const underTest = require('../../../src/core/content/formatted-node-title');
describe('formattedNodeTitle', function () {
	'use strict';
	[
		['a text title with no link', 'hello', 'hello'],
		['an empty string if nothing provided', undefined, ''],
		['a title without link if title contains text followed by link', 'hello www.google.com', 'hello'],
		['a title without link if title contains link followed by text', 'www.google.com hello', 'hello'],
		['a title without link if title contains link surrounded by text', 'hello www.google.com bye', 'hello bye'],
		['a title with second link if title contains multiple links with text', 'hello www.google.com www.google.com', 'hello www.google.com'],
		['a title with second link if title contains multiple links', 'www.google.com www.google.com', 'www.google.com'],
		['a link if title is link only', 'www.google.com', 'www.google.com']
	].forEach(function (args) {
		it('should return ' + args[0], function () {
			expect(underTest(args[1])).toEqual(args[2]);
		});
	});
	it('truncates link-only titles if maxlength is provided', function () {
		expect(underTest('http://google.com/search?q=onlylink', 25)).toEqual('http://google.com/search?...');
		expect(underTest('http://google.com/search?q=onlylink', 100)).toEqual('http://google.com/search?q=onlylink');
	});
	it('does not truncate links if maxlength is not provided', function () {
		expect(underTest('http://google.com/search?q=onlylink')).toEqual('http://google.com/search?q=onlylink');
	});
	it('does not truncate text even if maxlength is provided', function () {
		expect(underTest('http google.com search?q=onlylink', 25)).toEqual('http google.com search?q=onlylink');
	});
	it('replaces multiple spaces with a single space', function () {
		expect(underTest('something    else\t\t  again', 100)).toEqual('something else again');
	});
	it('removes non printable characters', () => {
		expect(underTest('abc\bdef', 100)).toEqual('abcdef');
		expect(underTest('abc\u0007def\u001Fghi\u0080jkl\u009Fx')).toEqual('abcdefghijklx');
	});
	it('trims lines but keeps new lines when replacing spaces', function () {
		expect(underTest('   something  \n\nelse\t \n\t  again  ', 100)).toEqual('something\n\nelse\nagain');
	});
	it('transforms windows line endings into linux line endings', function () {
		expect(underTest('something  \r\n\r\nelse\t\r\n\tagain', 100)).toEqual('something\n\nelse\nagain');
	});


});
