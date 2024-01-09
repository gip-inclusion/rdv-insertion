WebMock.disable_net_connect!(
  allow: ["127.0.0.1", "localhost", "chromedriver.storage.googleapis.com"]
)

Capybara.register_driver :selenium do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.chrome

  browser_options.add_argument("--window-size=1500,1000")

  unless ENV["WITH_BROWSER_VISIBLE"]
    browser_options.add_argument("--headless")
    browser_options.add_argument("--no-sandbox")
    browser_options.add_argument("--disable-gpu")
  end

  browser_options.add_preference(:download, prompt_for_download: false, default_directory: DownloadHelper::PATH.to_s)
  browser_options.add_preference(:browser, set_download_behavior: { behavior: "allow" })

  unless ENV['CI']
    Selenium::WebDriver::Chrome::Service.driver_path = ENV.fetch('CHROMEDRIVER_PATH', "/usr/local/bin/chromedriver")
  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: browser_options
  )
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium

Capybara.configure do |config|
  config.javascript_driver = :selenium
  config.server = :puma, { Silent: true }
  config.disable_animation = true
end
