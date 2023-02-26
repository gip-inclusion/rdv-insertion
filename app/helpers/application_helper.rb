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

  def compute_index_path(klass, organisation, department = nil, **params)
    if department_level?
      send("department_#{klass.name.underscore}s_path", department, **params.compact_blank)
    else
      send("organisation_#{klass.name.underscore}s_path", organisation, **params.compact_blank)
    end
  end

  def compute_new_path(klass, organisation, department = nil)
    return send("new_department_#{klass.name.underscore}_path", department) if department_level?

    send("new_organisation_#{klass.name.underscore}_path", organisation)
  end

  def compute_edit_path(record, organisation, department = nil)
    return send("edit_department_#{record.class.name.underscore}_path", department, record) if department_level?

    send("edit_organisation_#{record.class.name.underscore}_path", organisation, record)
  end

  def compute_show_path(record, organisation, department = nil)
    return send("department_#{record.class.name.underscore}_path", department, record) if department_level?

    send("organisation_#{record.class.name.underscore}_path", organisation, record)
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
