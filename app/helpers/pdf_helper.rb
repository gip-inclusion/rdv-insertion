module PdfHelper
  def pdf_stylesheet_pack_tag(source)
    return if Rails.env.test?

    stylesheet_pack_tag(source)
  end

  def pdf_image_tag(source)
    return if Rails.env.test?

    if Webpacker.manifest.lookup("media/images/logos/#{source}.svg")
      image_tag wicked_pdf_asset_pack_path("media/images/logos/#{source}.svg")
    elsif Webpacker.manifest.lookup("media/images/logos/#{source}.png")
      image_tag wicked_pdf_asset_pack_path("media/images/logos/#{source}.png")
    elsif Webpacker.manifest.lookup("media/images/logos/#{source}.jpg")
      image_tag wicked_pdf_asset_pack_path("media/images/logos/#{source}.jpg")
    end
  end
end
