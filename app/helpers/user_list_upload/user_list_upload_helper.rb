# rubocop:disable Metrics/ModuleLength
module UserListUpload::UserListUploadHelper
  def rows_with_errors?
    params[:rows_with_errors].present?
  end

  def user_row_status_badge_class(user_row)
    {
      to_create_with_no_errors: "background-blue-light text-mid-blue",
      to_create_with_errors: "alert-danger",
      to_update_with_no_errors: "background-blue-light text-mid-blue",
      to_update_with_errors: "alert-danger",
      up_to_date: "background-very-light-grey text-very-dark-grey"
    }[user_row.before_user_save_status]
  end

  def user_row_background_color(user_row)
    if user_row.archived?
      "background-brown-light"
    elsif user_row.selected_for_user_save?
      "background-light"
    end
  end

  def user_row_icon_for_status(errors)
    return if errors.empty?

    content_tag(:i, nil, class: "ri-alert-line text-end")
  end

  def user_row_status_text(status)
    {
      to_create_with_no_errors: "À créer",
      to_create_with_errors: "À créer",
      to_update_with_no_errors: "À mettre à jour",
      to_update_with_errors: "À mettre à jour",
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
        "background-brown-light text-brown"
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
      tooltip_errors(
        title: "Erreurs des données du dossier",
        errors: user_row.user_errors.full_messages
      )
    else
      tooltip(content: tooltip_content_for_user_row(user_row))
    end
  end

  def tooltip_content_for_user_row(user_row)
    tooltip_content_array = []
    tooltip_content_array << tooltip_content_for_user_row_archived(user_row) if user_row.archived?
    tooltip_content_array << tooltip_content_for_user_row_follow_up_closed if user_row.matching_user_follow_up_closed?
    if tooltip_content_array.empty?
      tooltip_content_array << if user_row.matching_user_id
                                 "Ce dossier existe déjà. Si coché, les données seront mises à jour"
                               else
                                 "Ce dossier n'existe pas encore. Si coché, celui-ci sera créé"
                               end
    end
    safe_join(tooltip_content_array, safe_join([tag.br, tag.br]))
  end

  # rubocop:disable Metrics/AbcSize
  def tooltip_content_for_user_row_archived(user_row)
    if user_row.department_level?
      safe_join(
        [
          tag.b("Dossier archivé sur #{strip_tags(user_row.archives.map(&:organisation).map(&:name).join(', '))}."),
          tag.br,
          "Motifs d'archivage : #{strip_tags(user_row.archiving_reasons.join(', '))}",
          tag.br,
          "Si mis à jour dans l'organisation d'archivage, le dossier sera désarchivé dans cette organisation."
        ]
      )
    else
      safe_join([
                  tag.b("Dossier archivé sur cette organisation."),
                  tag.br,
                  "Motif d'archivage : \"#{strip_tags(user_row.archiving_reasons.first)}\"",
                  tag.br,
                  "Si coché, le dossier sera désarchivé lors de la mise à jour."
                ])
    end
  end
  # rubocop:enable Metrics/AbcSize

  def tooltip_content_for_user_row_follow_up_closed
    safe_join([
                tag.b("Dossier traité sur cette catégorie"),
                tag.br,
                "Si coché, le dossier sera rouvert sur cette catégorie de suivi."
              ])
  end

  def show_row_attribute?(attribute_name, user_list_upload)
    user_list_upload.restricted_user_attributes.exclude?(attribute_name.to_sym)
  end

  def checkbox_to_select_all_checked?(attribute_name, user_list_upload_id)
    cookie_data = JSON.parse(cookies["user_list_uploads"] || "{}")
    cookie_data.dig(user_list_upload_id.to_s, "checkbox_all", attribute_name.to_s) != false
  rescue JSON::ParserError
    Sentry.capture_exception(JSON::ParserError, extra: { cookies: cookies["user_list_uploads"] })
    false
  end
end
# rubocop:enable Metrics/ModuleLength
