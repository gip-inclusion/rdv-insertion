class ComputeLogoFormat < BaseService
  def initialize(logo_name:)
    @logo_name = logo_name
  end

  def call
    fail!("aucun logo n'existe avec ce nom") if logo_format.nil?
    result.format = logo_format
  end

  private

  def logo_format
    %w[svg png jpg].find do |format|
      Webpacker.manifest.lookup("media/images/logos/#{@logo_name}.#{format}")
    end
  end
end
