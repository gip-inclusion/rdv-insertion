class PdfGeneratorClient
  FARADAY_TIMEOUT_SECONDS = ENV.fetch("PDF_GENERATOR_CLIENT_TIMEOUT", 45).to_i

  def self.generate_pdf(content:, margins: default_margins)
    conn.post("/generate") do |req|
      req.body = {
        htmlContent: content,
        **margins
      }.to_json
    end
  end

  def self.conn
    @conn ||= Faraday.new(url: ENV["PDF_GENERATOR_URL"]) do |f|
      f.headers["Authorization"] = ENV["PDF_GENERATOR_API_KEY"]
      f.headers["Content-Type"] = "application/json"
      f.options.timeout = FARADAY_TIMEOUT_SECONDS
      f.options.open_timeout = 10
    end
  end

  def self.default_margins
    {
      marginTop: "0cm",
      marginRight: "0cm",
      marginBottom: "0cm",
      marginLeft: "0cm"
    }
  end
  private_class_method :conn, :default_margins
end
