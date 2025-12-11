module MessagesConfigurationsHelper
  def messages_configuration_logo_types_collection
    MessagesConfiguration::LOGO_TYPES.map do |logo|
      [logo, I18n.t("activerecord.attributes.messages_configuration.logo_types.#{logo}")]
    end
  end

  def messages_configuration_placeholder(messages_configuration, attribute)
    current_value = messages_configuration.send(attribute)
    return if current_value.present?

    default_value = messages_configuration.send("default_#{attribute}")
    display_value = default_value.is_a?(Array) ? default_value.first : default_value
    "#{display_value} (par défaut)"
  end
end
