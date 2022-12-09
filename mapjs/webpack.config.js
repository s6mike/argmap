/*global require, module, __dirname, process */
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
module.exports = {
	watch: true,
	entry: [path.resolve(__dirname, 'src/start')],
	mode: 'development',
	// mode: 'production',
	// Use for production:
	// 	TODO: Change so this is set automatically when mode is set:
	// 	devtool: 'source-map',
	// Use for development:
	// 	configuration.devtool should match pattern "^(inline-|hidden-|eval-)?(nosources-)?(cheap-(module-)?)?source-map$".
	devtool: 'eval-cheap-module-source-map',
	output: {
		path: path.resolve(__dirname, 'site/js/'),
		// TODO: use more robust publicPath
		//	 publicPath: path.resolve(__dirname, 'site/js/'),
		publicPath: '/js/',
		filename: '[name].bundle.[contenthash].js',
		chunkFilename: '[name].chunk.js',
		clean: true,
	},
	plugins: [
		// new BundleAnalyzerPlugin(),
		new HtmlWebpackPlugin({
			template: path.resolve(__dirname, '/src/templates/template-webpack-dist-tags.html'),
			filename: path.resolve(__dirname, '../includes/webpack-dist-tags.html'),
		}),
	],
	optimization: {
		moduleIds: 'deterministic',
		splitChunks: {
			chunks: 'all',
			name: 'vendor',
			// minSize: 10000,
			// // production warning is at 244 KiB = 31232
			// maxSize: 31232
		},
	},
	devServer: {
		static: path.join(__dirname, 'site'),
		port: process.env.PORT_DEV_SERVER,
		watchFiles: ['src/**.js'],
	},
	module: {
		rules: [
			{
				test: require.resolve('jquery-hammerjs/jquery.hammer-full.js'),
				loader: 'exports-loader',
				options: {
					type: 'commonjs',
					exports: {
						syntax: 'single',
						name: 'Hammer',
					},
				},
			},
			{
				test: require.resolve('jquery.hotkeys'),
				use: [
					{
						loader: 'imports-loader',
						options: {
							type: 'commonjs',
							imports:
							{
								syntax: 'single',
								moduleName: 'jquery',
								name: 'jQuery',
							},
						},
					},
				],
			},
		],
	},
};
