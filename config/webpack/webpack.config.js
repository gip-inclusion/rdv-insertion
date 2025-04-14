const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const RemoveEmptyScriptsPlugin = require("webpack-remove-empty-scripts");
// The RAILS_ENV variable is set as "development" in Procfile.dev
const mode = (process.env.RAILS_ENV === "development" || process.env.RAILS_ENV === "test") ? "development" : "production";

module.exports = {
  mode,
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
    super_admin: "./app/javascript/super_admin.js",
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
      "process.env.RDV_SOLIDARITES_URL": JSON.stringify(process.env.RDV_SOLIDARITES_URL),
      "process.env.CARNET_DE_BORD_URL": JSON.stringify(process.env.CARNET_DE_BORD_URL),
      "process.env.RAILS_ENV": JSON.stringify(process.env.RAILS_ENV),
      "process.env.MATOMO_CONTAINER_ID": JSON.stringify(process.env.MATOMO_CONTAINER_ID),
      "process.env.CRISP_WEBSITE_ID": JSON.stringify(process.env.CRISP_WEBSITE_ID),
    }),
    // Include plugins
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ],
};
