Grover.configure do |config|
  config.options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true
  }
  if ENV["CI"]
    config.options = {
      print_background: true,
      format: "A4",
      executable_path: "/usr/bin/chromium-browser",
      args: ["--no-sandbox", "--disable-setuid-sandbox"]
    }
  end
end
