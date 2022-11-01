const path = require('path');
module.exports = {
  entry: path.resolve(__dirname, 'src') + '/js/index',
  devtool: 'cheap-module-eval-source-map',
  mode: "development",
  output: {
    filename: 'argmap.js',
    path: path.resolve(__dirname, 'mapjs/site/js/')
  },
  module: {
    rules: [
      {
        test: /\.lua$/,
        include: ['/home/s6mike/git_projects/argmap/src', '/home/s6mike/git_projects/argmap/lua_modules/share/lua/5.3',],
        use: [
          { loader: "fengari-loader" }
        ]
      }
    ]
  }
}