module ApplicationHelper
  def alert_class_for(type)
    case type
    when :success
      "alert-success"
    when :alert
      "alert-warning"
    when :error
      "alert-danger"
    when :notice
      "alert-info"
    else
      alert.to_s
    end
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

  def show_login_button?
    current_agent.nil? && controller_name.include?("static_pages")
  end

  def show_guide_banner?
    show_login_button?
  end

  def url_params
    Rack::Utils.parse_nested_query(request.query_string).deep_symbolize_keys
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flashes", partial: "common/flash"
  end

  def super_admin_acts_as_another_agent?
    super_admin_credentials = session.dig(:rdv_solidarites_credentials, "super_admin_id")
    super_admin_credentials.present? && super_admin_credentials.to_i != current_agent.id
  end
end
