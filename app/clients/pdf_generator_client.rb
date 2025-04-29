class PdfGeneratorClient
  def initialize
    @conn = Faraday.new(url: ENV["PDF_GENERATOR_URL"]) do |f|
      f.headers["Authorization"] = ENV["PDF_GENERATOR_API_KEY"]
      f.headers["Content-Type"] = "application/json"
    end
  end

  def generate_pdf(content:, margins: default_margins)
    @conn.post("/generate") do |req|
      req.body = {
        htmlContent: content,
        **margins
      }.to_json
    end
  end

  private

  def default_margins
    {
      marginTop: "0cm",
      marginRight: "0cm",
      marginBottom: "0cm",
      marginLeft: "0cm"
    }
  end
end
