module PdfHelper
  def extract_raw_text(pdf)
    pdf.pages
       .map(&:text)
       .join(" ")
       .gsub("\t", " ")
       .gsub("\n", " ")
       .gsub(/ +/, " ")
  end
end
