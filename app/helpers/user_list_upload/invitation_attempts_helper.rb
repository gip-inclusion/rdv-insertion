module UserListUpload::InvitationAttemptsHelper
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

    tooltip_errors_tag_attributes(
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
    selected_invitation_formats =
      cookies["selected_invitation_formats_#{user_list_upload_id}"] || %w[sms email]
    selected_invitation_formats = JSON.parse(selected_invitation_formats) if selected_invitation_formats.is_a?(String)
    selected_invitation_formats
  end
end
