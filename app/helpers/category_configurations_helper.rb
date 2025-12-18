module CategoryConfigurationsHelper
  def phone_number_with_default(category_configuration)
    phone_number = category_configuration.phone_number
    is_default = category_configuration.attributes["phone_number"].blank?
    "#{phone_number}#{' (par défaut)' if is_default}"
  end

  def invitation_formats_list(category_configuration)
    return if category_configuration.invitation_formats.blank?

    category_configuration.invitation_formats.map { |format| I18n.t("invitation_formats.#{format}") }.join(", ")
  end

  def invitations_validity_in_days(category_configuration)
    return unless category_configuration.invitations_expire?

    "#{category_configuration.number_of_days_before_invitations_expire} jours"
  end
end
