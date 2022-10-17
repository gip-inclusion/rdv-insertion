class Logo
  BASE_PATH = "media/images/logos/".freeze

  def initialize(name)
    @name = name
  end

  def path(selected_formats = [])
    return if formats.empty?

    format = selected_formats.any? ? selected_formats.find { |f| f.in?(formats) } : formats.first
    return if format.nil?

    "#{BASE_PATH}#{@name}.#{format}"
  end

  def formats
    %w[svg png jpg].select do |format|
      Webpacker.manifest.lookup("#{BASE_PATH}#{@name}.#{format}")
    end
  end
end
