module PdfHelper
  def extract_raw_text(pdf)
    pdf.pages
       .map(&:text)
       .join(" ")
       .gsub("\t", " ")
       .gsub("\n", " ")
       .gsub(/ +/, " ")
  end

  def mock_pdf_service(success: true, pdf_content: "mock pdf content")
    allow_any_instance_of(PdfGeneratorClient).to receive(:generate_pdf).and_return(
      instance_double(
        Faraday::Response,
        success?: success,
        body: success ? Base64.encode64(pdf_content) : "error",
        status: success ? 200 : 500
      )
    )
  end
end
