const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const RemoveEmptyScriptsPlugin = require("webpack-remove-empty-scripts");

module.exports = {
  mode: process.env.NODE_ENV,
  devtool: "source-map",
  output: {
    filename: "[name].js",
    chunkFilename: "[name]-[contenthash].digested.js",
    sourceMapFilename: "[file]-[fullhash].map",
    path: path.resolve(__dirname, "..", "..", "app/assets/builds"),
    hashFunction: "sha256",
    hashDigestLength: 64,
  },
  entry: {
    application: "./app/javascript/application.js",
    mail: "./app/javascript/mail.js",
    pdf: "./app/javascript/pdf.js",
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.(jsx)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"],
      },
    ],
  },

  resolve: {
    // Add additional file types
    extensions: [".js", ".jsx", ".scss", ".css"],
  },
  plugins: [
    new webpack.DefinePlugin({
      "process.env": JSON.stringify(process.env),
    }),
    // Include plugins
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ],
};
