module HasLogo
  delegate :path, to: :logo, prefix: true

  def logo
    Logo.new(name.parameterize)
  end
end
