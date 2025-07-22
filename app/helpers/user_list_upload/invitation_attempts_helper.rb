# rubocop:disable Metrics/ModuleLength
module UserListUpload::InvitationAttemptsHelper
  def user_row_background_color_before_invitation(user_row)
    "background-light" if user_row.selected_for_invitation?
  end

  def user_row_before_invitation_badge_class(user_row)
    {
      already_invited: "alert-success",
      invitable: "alert-info",
      not_invitable: "alert-danger"
    }[user_row.before_invitation_status]
  end

  def user_row_before_invitation_status_text(user_row)
    case user_row.before_invitation_status
    when :already_invited
      "Invité le #{user_row.previously_invited_at.strftime('%d/%m/%Y')}"
    when :invitable
      "Non invité"
    when :not_invitable
      "Ne peut être invité"
    end
  end

  def tooltip_content_for_user_row_before_invitation(user_row)
    case user_row.before_invitation_status
    when :already_invited
      tooltip_content_for_user_row_before_invitation_already_invited(user_row)
    when :invitable
      tooltip_content_for_user_row_before_invitation_invitable(user_row)
    when :not_invitable
      tooltip_content_for_user_row_before_invitation_not_invitable(user_row)
    end
  end

  def user_row_status_after_invitation_text(after_invitation_status)
    {
      invited: "Invitations envoyées",
      pending: "En cours",
      error: "Erreur"
    }[after_invitation_status]
  end

  def tooltip_for_invitation_errors(user_row)
    return unless user_row.all_invitations_failed?

    tooltip_errors(
      title: "Erreurs lors de l'envoi des invitations",
      errors: user_row.invitation_errors.uniq
    )
  end

  def user_row_status_after_invitation_badge_class(after_invitation_status)
    {
      invited: "alert-success",
      pending: "background-blue-light text-info border-blue"
    }[after_invitation_status]
  end

  def time_remaining_for_invitations(current_count, total_count)
    # we assume that each invitations takes 2 seconds
    ((total_count - current_count) * 2).seconds
  end

  def text_for_time_remaining_for_invitations(current_count, total_count)
    time_remaining = time_remaining_for_invitations(current_count, total_count)
    time_remaining_in_minutes = (time_remaining / 60).round
    if time_remaining < 1.minute
      "moins d'une minute restante"
    else
      "environ #{time_remaining_in_minutes} min restante#{'s' if time_remaining_in_minutes > 1}"
    end
  end

  def disable_invitation_for_user_row?(user_row)
    !user_row.invitable? ||
      selected_invitation_formats(user_row.user_list_upload_id).none? do |format|
        user_row.can_be_invited_through?(format)
      end
  end

  def invitation_format_checked?(format, user_list_upload_id)
    selected_invitation_formats(user_list_upload_id).include?(format)
  end

  def selected_invitation_formats(user_list_upload_id)
    cookie_data = JSON.parse(cookies["user_list_uploads"] || "{}")
    formats = cookie_data.dig(user_list_upload_id.to_s, "selected_invitation_formats")
    formats.is_a?(Array) ? formats : %w[sms email]
  rescue JSON::ParserError
    Sentry.capture_exception(JSON::ParserError, extra: { cookies: cookies["user_list_uploads"] })
    %w[sms email]
  end

  private

  def tooltip_content_for_user_row_before_invitation_invitable(user_row)
    safe_join(
      [
        tag.b("Cette usager n'a pas encore été invité sur cette catégorie de suivi."),
        tag.br,
        "Vous pouvez l'inviter par #{user_invitable_by_formats_sentence(user_row)}."
      ]
    )
  end

  def user_invitable_by_formats_sentence(user_row)
    user_row.invitable_by_formats.map do |format|
      I18n.t("activerecord.attributes.invitation.formats.#{format}")
    end.to_sentence(last_word_connector: " ou ", two_words_connector: " ou ")
  end

  def tooltip_content_for_user_row_before_invitation_already_invited(user_row)
    content_array = [
      tag.b("Cette usager a déjà été invité sur cette catégorie" \
            " le #{user_row.previously_invited_at.strftime('%d/%m/%Y')}.")
    ]

    if user_row.invited_less_than_24_hours_ago?
      content_array << tag.br
      content_array << "Attendez 24 heures pour pouvoir lui renvoyer une invitation."
    end

    safe_join(content_array)
  end

  def tooltip_content_for_user_row_before_invitation_not_invitable(user_row)
    case user_row.invitable_by_formats
    when []
      safe_join(
        [
          tag.b("Cette usager ne peut pas être invité."),
          tag.br,
          "Il faut au moins une donnée de contact (téléphone, email ou adresse postale)."
        ]
      )
    when %w[postal]
      safe_join(
        [
          tag.b("Cette usager ne peut pas être invité numériquement."),
          tag.br,
          "Il faut au moins un numéro de téléphone ou une adresse email."
        ]
      )
    # should never happen
    else
      "Cette usager ne peut pas être invité."
    end
  end
end
# rubocop:enable Metrics/ModuleLength
