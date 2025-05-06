module UserListUpload::InvitationAttemptsHelper
  def user_row_background_color_before_invitation(user_row)
    "background-light" if user_row.selected_for_invitation?
  end

  def user_row_before_invitation_badge_class(user_row)
    {
      already_invited: "background-very-light-grey text-very-dark-grey",
      not_invited: "background-blue-light text-mid-blue"
    }[user_row.before_invitation_status]
  end

  def user_row_before_invitation_status_text(user_row)
    return "Non invité" if user_row.before_invitation_status == :not_invited

    "Invité le #{user_row.previously_invited_at.strftime('%d/%m/%Y')}"
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
      pending: "background-blue-light text-mid-blue"
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
    selected_invitation_formats(user_row.user_list_upload_id).none? { |format| user_row.invitable_by?(format) }
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
end
