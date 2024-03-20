module HasCurrentConfiguration
  def current_configuration
    @current_configuration ||= configurations.find { |c| c.motif_category == motif_category }
  end
end
