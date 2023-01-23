WebMock.disable_net_connect!(
  allow: ["127.0.0.1", "localhost", "chromedriver.storage.googleapis.com"]
)
Capybara.register_driver :selenium do |app|
  # these args seem to reduce test flakyness
  args = %w[headless no-sandbox disable-gpu window-size=1500,1000]

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: [Selenium::WebDriver::Chrome::Options.new(
      args: args,
      "goog:loggingPrefs": { browser: "ALL" }
    )]
  )
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium

Capybara.configure do |config|
  config.javascript_driver = :selenium
  config.server = :puma, { Silent: true }
  config.disable_animation = true
end
