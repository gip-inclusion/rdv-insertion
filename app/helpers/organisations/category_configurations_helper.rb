module Organisations::CategoryConfigurationsHelper
  def display_category_configuration_phone_number(category_configuration)
    return if category_configuration.phone_number.blank?

    if category_configuration.default_phone_number?
      "#{category_configuration.phone_number} (par défaut)"
    else
      category_configuration.phone_number
    end
  end

  def display_invitation_formats(invitation_formats)
    return if invitation_formats.blank?

    invitation_formats.map { |format| I18n.t("invitation_formats.#{format}") }.join(", ")
  end

  def display_number_of_days_before_invitations_expire(number_of_days_before_invitations_expire)
    if number_of_days_before_invitations_expire.nil?
      "Pas de limite"
    else
      "#{number_of_days_before_invitations_expire} jours"
    end
  end
end
