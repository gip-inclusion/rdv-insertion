class Logo
  BASE_PATH = "media/images/logos/".freeze

  def initialize(name)
    @name = name
  end

  def path
    format.nil? ? nil : "#{BASE_PATH}#{@name}.#{format}"
  end

  def format
    %w[svg png jpg].find do |format|
      Webpacker.manifest.lookup("#{BASE_PATH}#{@name}.#{format}")
    end
  end
end
