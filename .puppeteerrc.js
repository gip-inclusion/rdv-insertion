const {join} = require('path');

/**
 * @type {import('puppeteer').Configuration}
 */
module.exports = {
  cacheDirectory: join(__dirname, '.cache', 'puppeteer'),
  skipDownload: true,
  executablePath: '/usr/bin/chromium-browser',
};