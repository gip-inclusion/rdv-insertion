Grover.configure do |config|
  default_options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true
  }
  config.options = default_options
end
