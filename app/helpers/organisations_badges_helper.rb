module OrganisationsBadgesHelper
  def css_classes_for_organisation_badge(archive)
    html_escape(
      "badge badge-tag justify-content-between text-dark-blue me-2 mb-2 d-flex text-truncate"
        .concat(archive.nil? ? " background-blue-light" : " background-warning")
    )
  end

  def tooltip_for_archived_organisation_badge(archive)
    return if archive.nil?

    tooltip_tag_attributes(
      stimulus_action: "mouseover->tooltip#organisationArchiveInformations",
      archive_creation_date: format_date(archive.created_at),
      archive_reason: archive.archiving_reason,
      show_archiving_reason: policy(archive).show?
    )
  end
end
