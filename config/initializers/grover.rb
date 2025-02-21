Grover.configure do |config|
  config.options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true,
    launch_args: [
      "--no-sandbox"
    ]
  }
end
