# rubocop:disable Metrics/ModuleLength
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

  def user_row_background_color(user_row)
    if user_row.archived?
      "background-maroon-light"
    else
      "background-light"
    end
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
    elsif attribute_to_highlight?(user_row, attribute)
      "alert-success"
    else
      ""
    end
  end

  def user_row_icon_for_attribute(user_row, attribute)
    if user_row.user_errors.attribute_names.include?(attribute)
      content_tag(
        :i, nil, class: "ri-alert-line text-end", **tooltip_errors_attributes(
          title: "Erreur sur cette donnée",
          errors: user_row.user_errors.full_messages_for(attribute)
        )
      )
    elsif attribute_to_highlight?(user_row, attribute)
      content_tag(:i, nil, class: "ri-checkbox-circle-line text-end")
    else
      ""
    end
  end

  def attribute_to_highlight?(user_row, attribute)
    user_row.matching_user_attribute_changed?(attribute) || user_row.attribute_changed_by_cnaf_data?(attribute)
  end

  def badge_class_for_user_row_organisation(user_row, organisation)
    if user_row.association_already_persisted?(organisation, :organisations)
      if user_row.archives.map(&:organisation_id).include?(organisation.id)
        "background-maroon-light text-maroon"
      else
        "background-blue-light text-dark-blue"
      end
    else
      "background-green-light text-dark-green"
    end
  end

  def badge_class_for_user_row_motif_category(user_row, motif_category)
    if user_row.association_already_persisted?(motif_category, :motif_categories)
      if user_row.user.follow_up_for(motif_category)&.closed?
        "background-dark-green text-white"
      else
        "background-blue-light text-dark-blue"
      end
    else
      "background-green-light text-dark-green"
    end
  end

  def tooltip_for_user_row(user_row)
    if user_row.user_errors.any?
      tooltip_errors_tag_attributes(
        title: "Erreurs des données du dossier",
        errors: user_row.user_errors.full_messages
      )
    else
      tooltip_with_content(tooltip_content_for_user_row(user_row))
    end
  end

  def tooltip_content_for_user_row(user_row)
    tooltip_content_array = []
    tooltip_content_array << tooltip_content_for_user_row_archived(user_row) if user_row.archived?
    tooltip_content_array << tooltip_content_for_user_row_follow_up_closed if user_row.matching_follow_up_closed?
    if tooltip_content_array.empty?
      tooltip_content_array << if user_row.matching_user_id
                                 "Ce dossier existe déjà. Si coché, les données seront mises à jour"
                               else
                                 "Ce dossier n'existe pas encore. Si coché, celui-ci sera créé"
                               end
    end
    tooltip_content_array.join("<br/><br/>")
  end

  def tooltip_content_for_user_row_archived(user_row)
    if user_row.department_level?
      "<b>Dossier archivé sur #{user_row.archives.map(&:organisation).map(&:name).join(', ')}.</b> <br/>" \
        "Motifs d'archivage : #{user_row.archiving_reasons.join(', ')}<br/>" \
        "Si mis à jour dans l'organisation d'archivage, le dossier sera désarchivé dans cette organisation."
    else
      "<b>Dossier archivé sur cette organisation.</b> <br/>" \
        "Motif d'archivage : \"#{user_row.archiving_reasons.first}\"<br/>" \
        "Si coché, le dossier sera désarchivé lors de la mise à jour."
    end
  end

  def tooltip_content_for_user_row_follow_up_closed
    "<b>Dossier traité sur cette catégorie</b><br/>" \
      "Si coché, le dossier sera rouvert sur cette catégorie de suivi."
  end

  def show_row_attribute?(attribute_name, user_list_upload)
    user_list_upload.restricted_user_attributes.exclude?(attribute_name.to_sym)
  end

  def checkbox_to_select_all_checked?(attribute_name, user_list_upload_id)
    cookies["checkbox_to_select_all_#{attribute_name}_checked_#{user_list_upload_id}"] != "false"
  end
end
# rubocop:enable Metrics/ModuleLength
