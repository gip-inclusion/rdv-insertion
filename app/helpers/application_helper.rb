module ApplicationHelper
  def alert_class_for(type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[type] || type.to_s
  end

  def icon_class_for(type)
    {
      success: "ri-checkbox-circle-fill",
      error: "ri-close-circle-fill",
      alert: "ri-error-warning-fill",
      notice: "ri-information-fill"
    }[type] || "ri-information-fill"
  end

  def display_attribute(attribute)
    attribute.presence || " - "
  end

  def display_date(date)
    display_attribute(format_date(date))
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
    return false if current_structure_type_in_params.blank?

    current_agent_department_organisations && current_agent_department_organisations.length > 1
  end

  def url_params
    Rack::Utils.parse_nested_query(request.query_string).deep_symbolize_keys
  end

  def tooltip_attributes(stimulus_action:, **dataset)
    attributes = {
      data: {
        controller: "tooltip",
        action: stimulus_action
      }.merge(dataset || {})
    }

    tag.attributes(attributes)
  end

  def display_tooltip_errors(title:, errors:)
    tag.attributes(
      data: {
        controller: "tooltip",
        action: "mouseover->tooltip#showErrors",
        title: title,
        errors: errors.to_json
      }
    )
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flashes", partial: "common/flashes"
  end

  def structure_name_with_context(structure)
    if structure.is_a?(Department)
      "#{structure.name} - Toutes les organisations"
    else
      structure.name
    end
  end
end
