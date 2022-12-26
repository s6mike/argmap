/*global require, module, __dirname, process */
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
module.exports = {
	entry: [path.resolve(__dirname, 'src/start.js')],
	mode: 'development',
	// mode: 'production',
	// Use for production:
	// 	TODO: Change so this is set automatically when mode is set:
	// 	devtool: 'source-map',
	// Use for development:
	// 	configuration.devtool should match pattern "^(inline-|hidden-|eval-)?(nosources-)?(cheap-(module-)?)?source-map$".
	devtool: 'eval-cheap-module-source-map',
	output: {
		path: path.resolve(__dirname, 'public/js/'),
		// TODO: use more robust publicPath
		//	 publicPath: path.resolve(__dirname, 'public/js/'),
		publicPath: '/js/',
		// Setting filename as anything except '[name].js' breaks one of HMR/watch mode/live reloading
		//  Think watch mode may have fixed this but then get warning when running server
		//  TODO: either solve this or set this name in production only:
		// filename: '[name].[contenthash].bundle.js',
		chunkFilename: '[name].[contenthash].bundle.js', // This is used for on-demand-loaded chunk files.
		clean: true,
	},
	devServer: {
		static: path.join(__dirname, 'public'),
		port: process.env.PORT_DEV_SERVER,
		client: {
			overlay: false,
			progress: false,
		},
		// watchFiles: ['src/**.js'],
	},
	plugins: [
		// new BundleAnalyzerPlugin(),
		new HtmlWebpackPlugin({
			filename: path.resolve(__dirname, '../includes/webpack-dist-tags.html'),
			// Outputs script tags only:
			inject: 'body',
			templateContent: '',
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
	module: {
		rules: [
			// {
			// 	test: require.resolve('jquery-hammerjs/jquery.hammer-full.js'),
			// 	loader: 'exports-loader',
			// 	options: {
			// 		type: 'commonjs',
			// 		exports: {
			// 			syntax: 'single',
			// 			name: 'Hammer',
			// 		},
			// 	},
			// },
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
