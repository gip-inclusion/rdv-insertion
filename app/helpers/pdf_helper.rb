module PdfHelper
  def logo_path(name, formats = [])
    Logo.new(name).path(formats)
  end
end
