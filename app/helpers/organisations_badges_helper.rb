module OrganisationsBadgesHelper
  def css_classes_for_organisation_badge(archive)
    html_escape(
      "badge badge-tag justify-content-between text-dark-blue me-2 mb-2 d-flex text-truncate"
        .concat(archive.nil? ? " background-blue-light" : " background-warning")
    )
  end

  def tooltip_for_archived_organisation_badge(archive)
    return if archive.nil?

    attributes = {
      data: {
        controller: "tooltip",
        action: "mouseover->tooltip#organisationArchiveInformations",
        "archive-creation-date": format_date(archive.created_at),
        "archive-reason": archive.archiving_reason,
        "show-archiving-reason": policy(archive).show?
      }
    }

    html_escape(tag.attributes(attributes))
  end
end
