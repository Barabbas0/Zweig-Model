var path = require('path');
var webpack = require('webpack');
var entryPath = path.join(__dirname, 'src/entry.js');
console.log("entryPath:");
console.log(entryPath);


module.exports = {
  devtool: 'source-map',
  
  entry: entryPath,
  
  output: {
    path: path.join(__dirname, 'public'),
    filename: 'bundle.js',
    publicPath: '/public/'
  },
  
  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      minimize: true,
      compress: {
        warnings: false
      }
    })
  ],
  
  resolve: {
    extensions: ['', '.js', '.jsx']
  },
  
  module: {
    loaders: [
      { test: /\.jsx$/,
        loader: 'babel',
        include: path.join(__dirname, 'src') },
      { test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/ },
      { test: /\.scss?$/,
        loader: 'style!css!sass',
        include: path.join(__dirname, 'css') },
    ]
  }
}