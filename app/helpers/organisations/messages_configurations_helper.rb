module Organisations::MessagesConfigurationsHelper
  def messages_configuration_logo_types_collection
    MessagesConfiguration::LOGO_TYPES.map do |logo|
      [logo, I18n.t("activerecord.attributes.messages_configuration.logo_types.#{logo}")]
    end
  end
end
