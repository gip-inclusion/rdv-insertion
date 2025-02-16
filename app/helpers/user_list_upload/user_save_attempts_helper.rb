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
      updated: "alert-success"
    }[status]
  end

  def user_save_status_text(status)
    {
      pending: "En cours",
      created: "Dossier créé",
      updated: "Mis à jour"
    }[status]
  end

  def user_row_background_color_for_attribute(user_row, attribute)
    return if user_row.user.valid?

    "alert-danger" if user_row.user_errors.attribute_names.include?(attribute)
  end

  def user_row_icon_for_attribute(user_row, attribute)
    return if user_row.user_errors.attribute_names.exclude?(attribute)

    content_tag(
      :i, nil, class: "ri-alert-line text-end", **tooltip_errors_attributes(
        title: "Erreur sur cette donnée",
        errors: user_row.user_errors.full_messages_for(attribute)
      )
    )
  end

  def tooltip_for_user_save_attempt_errors(errors)
    return if errors.blank?

    tooltip_errors_tag_attributes(
      title: "Erreurs lors de la sauvegarde du dossier",
      errors: errors
    )
  end
end
