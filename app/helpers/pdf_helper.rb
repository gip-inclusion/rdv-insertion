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
    return if Rails.env.test?

    logo_name = ComputeOrganisationOrDepartmentLogoName.call(
      department_name: department_name,
      organisation_name: organisation_name
    ).logo_name

    image_tag wicked_pdf_asset_pack_path("media/images/logos/#{logo_name}.#{logo_format(logo_name)}")
  end

  def logo_format(logo_name)
    ComputeLogoFormat.call(logo_name: logo_name).format
  end
end
