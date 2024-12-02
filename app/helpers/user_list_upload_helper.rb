module UserListUploadHelper
  def user_with_errors?
    params[:user_with_errors].present?
  end

  def user_status_badge_class(status)
    {
      to_create: "background-blue-light text-purple",
      to_update: "background-blue-light text-purple",
      up_to_date: "background-light-grey text-dark-grey"
    }[status]
  end

  def user_status_text(status)
    {
      to_create: "À créer",
      to_update: "À mettre à jour",
      up_to_date: "À jour"
    }[status]
  end

  def background_color_for_attribute(user_row, attribute)
    if user_row.errors.attribute_names.include?(attribute)
      "alert-danger"
    elsif user_row.attribute_changed?(attribute)
      "alert-success"
    else
      ""
    end
  end

  def icon_for_attribute(user_row, attribute)
    if user_row.errors.attribute_names.include?(attribute)
      content_tag(:i, nil, class: "ri-alert-line text-end")
    elsif user_row.attribute_changed?(attribute)
      content_tag(:i, nil, class: "ri-checkbox-circle-line text-end")
    else
      ""
    end
  end
end
