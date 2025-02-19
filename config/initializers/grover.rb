Grover.configure do |config|
  default_options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true
  }
  ci_options = {
    executable_path: "/usr/bin/chromium-browser"
  }
  config.options = ENV["CI"] ? default_options.merge(ci_options) : default_options
end
