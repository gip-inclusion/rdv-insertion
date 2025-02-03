module UserListUpload::UserSaveAttemptsHelper
  def time_remaining_for_saves(current_count, total_count)
    # we assume that each save takes 1 seconds
    ((total_count - current_count) * 1).seconds
  end

  def text_for_time_remaining_for_saves(current_count, total_count)
    time_remaining = time_remaining_for_saves(current_count, total_count)
    time_remaining_in_minutes = (time_remaining / 60).round
    if time_remaining < 1.minute
      "moins d'une minute restante"
    else
      "environ #{time_remaining_in_minutes} min restante#{'s' if time_remaining_in_minutes > 1}"
    end
  end

  def user_save_status_badge_class(status)
    {
      pending: "background-blue-light text-mid-blue",
      created: "alert-success",
      updated: "alert-success",
      organisation_needs_to_be_assigned: "alert-info",
      error: "alert-danger"
    }[status]
  end

  def user_save_status_text(status)
    {
      pending: "En cours",
      created: "Dossier créé",
      updated: "Mis à jour",
      organisation_needs_to_be_assigned: "Organisation à assigner",
      error: "Erreur"
    }[status]
  end

  def tooltip_for_user_save_attempt_errors(errors)
    return if errors.blank?

    tooltip_errors_tag_attributes(
      title: "Erreurs lors de la sauvegarde du dossier",
      errors: errors
    )
  end

  def user_save_icon_for_status(status)
    return "" unless status == :error

    content_tag(:i, nil, class: "ri-alert-line text-end")
  end
end
