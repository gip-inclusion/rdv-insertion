module HasLogo
  delegate :path, to: :logo, prefix: true

  def logo
    Logo.new(logo_name.parameterize)
  end

  def logo_name
    self.class.column_names.include?("logo_filename") ? logo_filename : name
  end
end
