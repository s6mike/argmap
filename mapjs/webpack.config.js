/*global require, module, __dirname */
const path = require('path');
module.exports = {
	entry: './src/start',
	devtool: 'source-map',
	output: {
		filename: 'bundle.js',
		path: path.resolve(__dirname, 'site/js/')
	},
	devServer: {
		contentBase: path.join(__dirname, 'site/js'),
		port: 9000
	}
};
