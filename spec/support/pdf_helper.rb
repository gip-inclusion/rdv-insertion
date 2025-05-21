module PdfHelper
  def mock_pdf_service(success: true, pdf_content: "mock pdf content")
    allow(PdfGeneratorClient).to receive(:generate_pdf).and_return(
      instance_double(
        Faraday::Response,
        success?: success,
        body: success ? Base64.encode64(pdf_content) : "error",
        status: success ? 200 : 500
      )
    )
  end
end
