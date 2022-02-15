module PdfHelper
  def pdf_stylesheet_pack_tag(source)
    if Rails.env.development?
      wicked_pdf_stylesheet_link_tag(source)
    else
      wicked_pdf_stylesheet_pack_tag(source)
    end
  end

  def pdf_image_tag(source)
    if Rails.env.development?
      image_pack_tag(source)
    else
      image_tag wicked_pdf_asset_pack_path(source)
    end
  end
end
