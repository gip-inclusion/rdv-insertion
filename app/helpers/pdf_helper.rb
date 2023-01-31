module PdfHelper
  def pdf_stylesheet_pack_tag(source)
    return if Rails.env.test?

    stylesheet_pack_tag(source)
  end

  def pdf_image_tag(path)
    return if Rails.env.test?

    image_tag wicked_pdf_asset_pack_path(path)
  end

  def logo_path(name, format = [])
    Logo.new(name).path(format)
  end
end
