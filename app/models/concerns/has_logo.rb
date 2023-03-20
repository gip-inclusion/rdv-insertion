module HasLogo
  delegate :path, to: :logo, prefix: true

  def logo
    Logo.new(logo_name.parameterize)
  end

  def logo_name
    respond_to?(:logo_filename) && logo_filename.present? ? logo_filename : name
  end
end
