Grover.configure do |config|
  config.options = {
    args: if Rails.env.test?
            ["--no-sandbox", "--disable-setuid-sandbox"]
          else
            []
          end
  }
end
