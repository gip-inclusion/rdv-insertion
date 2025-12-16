module Organisations::CategoryConfigurationsHelper
  def category_configuration_template_override_placeholder(category_configuration, attribute)
    current_value = category_configuration.send(attribute)
    return if current_value.present?

    default_value = category_configuration.send(attribute.to_s.gsub("_override", ""))
    "#{default_value} (par défaut)"
  end
end
