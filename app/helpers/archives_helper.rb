module ArchivesHelper
  def archived_scope?(scope)
    scope == "archived"
  end

  def organisation_archive(organisation, archives)
    archives.find { |archive| archive.organisation_id == organisation.id }
  end

  def user_archived_in?(user, organisations)
    UserArchivedStatus.new(user, organisations).archived?
  end

  def archived_banner_message(archived_organisations)
    names = archived_organisations.map(&:name).join(", ")
    wording = archived_organisations.size > 1 ? "les organisations" : "l'organisation"
    "Ce bénéficiaire est archivé sur #{wording} #{names}"
  end
end
