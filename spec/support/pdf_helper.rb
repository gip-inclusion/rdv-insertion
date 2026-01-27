module PdfHelper
  def mock_pdf_service(success: true)
    allow(PdfGeneratorClient).to receive(:generate_pdf) do |content:, **|
      instance_double(
        Faraday::Response,
        success?: success,
        body: success ? Base64.encode64(content) : "error",
        status: success ? 200 : 500
      )
    end
  end

  def letter_content(record)
    record.pdf_data.force_encoding("UTF-8")
  end
end
