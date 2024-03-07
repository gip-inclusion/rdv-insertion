module PdfHelper
  def pdf_stylesheet_link_tag(source)
    if Rails.env.test?
      # wicked_pdf_stylesheet_link_tag produces prevents from forming a pdf in test
      stylesheet_link_tag(source)
    else
      wicked_pdf_stylesheet_link_tag(source)
    end
  end
end
