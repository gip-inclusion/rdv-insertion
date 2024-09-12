WebMock.disable_net_connect!(
  allow: ["127.0.0.1", "localhost", "chromedriver.storage.googleapis.com", "http://www.rdv-solidarites-test.localhost"]
)

Capybara.register_driver :selenium do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.chrome

  browser_options.add_argument("--window-size=1500,1000")

  unless ENV["WITH_BROWSER_VISIBLE"]
    browser_options.add_argument("--headless")
    browser_options.add_argument("--no-sandbox")
    browser_options.add_argument("--disable-gpu")
    browser_options.add_argument("--disable-search-engine-choice-screen")
  end

  browser_options.add_preference(:download, prompt_for_download: false,
                                            default_directory: DownloadHelper.download_path.to_s)
  browser_options.add_preference(:browser, set_download_behavior: { behavior: "allow" })

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: browser_options
  )
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium
Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i

Capybara.configure do |config|
  config.javascript_driver = :selenium
  config.server = :puma, { Silent: true }
  config.disable_animation = true
end
