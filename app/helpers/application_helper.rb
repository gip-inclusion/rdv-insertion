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

  def date_input(form, field, label = nil, input_html: {}, **kwargs)
    form.input(
      field,
      as: :string,
      label: label,
      input_html: {
        value: form.object&.send(field)&.strftime("%d/%m/%Y"),
        data: { behaviour: "datepicker" },
        autocomplete: "off",
        placeholder: "__/__/___"
      }.deep_merge(input_html),
      **kwargs
    )
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
end
