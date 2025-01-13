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

  def user_row_status_after_invitation_icon_for_status(after_invitation_status)
    return "" unless after_invitation_status == :error

    content_tag(:i, nil, class: "ri-alert-line text-end")
  end

  def tooltip_for_invitation_errors(user_row)
    return unless user_row.all_invitations_failed?

    display_tooltip_errors(
      title: "Erreurs lors de l'envoi des invitations",
      errors: user_row.invitation_errors.uniq
    )
  end

  def user_row_status_after_invitation_badge_class(after_invitation_status)
    {
      invited: "alert-success",
      pending: "background-blue-light text-mid-blue",
      error: "alert-danger"
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
end
