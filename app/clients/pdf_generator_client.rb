class PdfGeneratorClient
  # Server-side timeout for PDF generation (sent to JS server)
  DEFAULT_SERVER_TIMEOUT_MS = 10_000
  # Faraday timeout should be higher to let server respond with proper error
  FARADAY_TIMEOUT_SECONDS = ENV.fetch("PDF_GENERATOR_CLIENT_TIMEOUT", 45).to_i

  def self.generate_pdf(content:, margins: default_margins, timeout: DEFAULT_SERVER_TIMEOUT_MS)
    conn.post("/generate") do |req|
      req.body = {
        htmlContent: content,
        timeout: timeout,
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
