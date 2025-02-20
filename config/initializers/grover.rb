Grover.configure do |config|
  default_options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true
  }
  production_options = {
    args: ["--no-sandbox"]
  }
  config.options = ENV["CI"] || Rails.env.production? ? default_options.merge(production_options) : default_options
end
