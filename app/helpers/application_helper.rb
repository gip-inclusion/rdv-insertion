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

  def translated_attribute_value(record, attribute)
    I18n.t("activerecord.attributes.#{record.class.name.downcase}.#{attribute.to_s.pluralize}.#{record[attribute]}")
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

  def asset_compiled?(asset_path)
    Webpacker.manifest.lookup(asset_path).present?
  end

  def image_compiled?(image_path)
    asset_compiled?("media/images/#{image_path}")
  end

  def show_login_button?
    !logged_in? && controller_name.include?("static_pages")
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
end
