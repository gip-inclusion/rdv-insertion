Grover.configure do |config|
  config.options = {
    format: "A4",
    # print_background is mandatory to print the css background colors
    print_background: true,
    root_path: Rails.root.join("puppeteer_modules").to_s,
    args: ["--no-sandbox"]
  }
end
