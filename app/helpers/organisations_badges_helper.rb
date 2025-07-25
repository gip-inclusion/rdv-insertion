module OrganisationsBadgesHelper
  def css_classes_for_organisation_badge(archive)
    html_escape(
      "badge badge-tag justify-content-between text-dark-blue me-2 mb-2 d-flex text-truncate"
        .concat(archive.nil? ? " background-blue-light border-blue border" : " background-warning")
    )
  end

  def tooltip_for_archived_organisation_badge(archive)
    return if archive.nil?

    content_array = ["Archivé le #{format_date(archive.created_at)}"]

    if policy(archive).show?
      content_array << tag.br
      content_array << "Motif : #{strip_tags(archive.archiving_reason.to_s)}"
    end

    tooltip(content: safe_join(content_array))
  end
end
