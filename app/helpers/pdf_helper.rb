module PdfHelper
  def pdf_stylesheet_pack_tag(source)
    return if Rails.env.test?

    stylesheet_pack_tag(source)
  end

  def pdf_image_tag(source)
    return if Rails.env.test?

    image_tag wicked_pdf_asset_pack_path("media/images/logos/#{source}.#{logo_format(source)}")
  end

  def organisation_or_department_logo(department_name, organisation_name = nil)
    logo_name = if organisation_name && logo_is_present(organisation_name)
                  organisation_name
                else
                  department_name
                end

    pdf_image_tag(logo_name)
  end

  def logo_is_present(logo_name)
    Webpacker.manifest.lookup("media/images/logos/#{logo_name}.svg") ||
      Webpacker.manifest.lookup("media/images/logos/#{logo_name}.png") ||
      Webpacker.manifest.lookup("media/images/logos/#{logo_name}.jpg")
  end

  def logo_format(logo_name)
    return "svg" if Webpacker.manifest.lookup("media/images/logos/#{logo_name}.svg")
    return "png" if Webpacker.manifest.lookup("media/images/logos/#{logo_name}.png")
    return "jpg" if Webpacker.manifest.lookup("media/images/logos/#{logo_name}.jpg")
  end
end
