module UserListUpload::UserListUploadHelper
  def rows_with_errors?
    params[:rows_with_errors].present?
  end

  def user_row_status_badge_class(user_row)
    return "alert-danger" if user_row.user_errors.any?

    {
      to_create: "background-blue-light text-mid-blue",
      to_update: "background-blue-light text-mid-blue",
      up_to_date: "background-very-light-grey text-very-dark-grey"
    }[user_row.before_user_save_status]
  end

  def user_row_icon_for_status(errors)
    return if errors.empty?

    content_tag(:i, nil, class: "ri-alert-line text-end")
  end

  def user_row_status_text(status)
    {
      to_create: "À créer",
      to_update: "À mettre à jour",
      up_to_date: "À jour"
    }[status]
  end

  def user_row_background_color_for_attribute(user_row, attribute)
    if user_row.user_errors.attribute_names.include?(attribute)
      "alert-danger"
    elsif user_row.attribute_changed?(attribute)
      "alert-success"
    else
      ""
    end
  end

  def tooltip_for_user_row_errors(errors)
    return if errors.empty?

    display_tooltip_errors(
      title: "Erreurs des données du dossier",
      errors: errors.full_messages
    )
  end

  def user_row_icon_for_attribute(user_row, attribute)
    if user_row.user_errors.attribute_names.include?(attribute)
      content_tag(:i, nil, class: "ri-alert-line text-end")
    elsif user_row.attribute_changed?(attribute)
      content_tag(:i, nil, class: "ri-checkbox-circle-line text-end")
    else
      ""
    end
  end

  def show_row_attribute?(attribute_name, user_list_upload)
    user_list_upload.restricted_user_attributes.exclude?(attribute_name.to_sym)
  end
end
