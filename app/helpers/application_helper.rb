module ApplicationHelper
  def alert_class_for(type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[type.to_sym] || type.to_s
  end

  def icon_class_for(type)
    {
      success: "far fa-check-circle fa-lg",
      error: "far fa-times-circle fa-lg",
      alert: "fas fa-exclamation-circle fa-lg",
      notice: "fas fa-info-circle fa-lg"
    }[type.to_sym] || "fas fa-info-circle fa-lg"
  end

  def display_attribute(attribute)
    attribute.presence || " - "
  end

  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def component_name_for_department(department_name)
    department_name.parameterize.capitalize
  end

  def asset_exists?(asset_path)
    AssetHelper.asset_exists?(asset_path)
  end

  def show_organisation_navigation_button?
    current_agent_department_organisations && current_agent_department_organisations.length > 1
  end

  def url_params
    Rack::Utils.parse_nested_query(request.query_string).deep_symbolize_keys
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flashes", partial: "common/flashes"
  end
end
