module PdfHelper
  def pdf_stylesheet_pack_tag(source)
    return if Rails.env.test?

    if Rails.env.development?
      stylesheet_pack_tag(source)
    else
      wicked_pdf_stylesheet_pack_tag(source)
    end
  end

  def pdf_image_tag(source)
    return if Rails.env.test?

    image_tag wicked_pdf_asset_pack_path("media/images/#{source}")
  end
end
