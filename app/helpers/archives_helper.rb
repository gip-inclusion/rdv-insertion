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

  def user_archives(user, organisations)
    UserArchivedStatus.new(user, organisations).user_archives_in_organisations
  end

  def archived_banner_message(archives)
    names = archives.map(&:organisation).sort.map(&:name).join(", ")
    wording = archives.size > 1 ? "les organisations" : "l'organisation"
    "Cet usager est archivé sur #{wording} #{names} (#{format_archives_reason(archives)})"
  end

  def format_archives_reason(archives)
    reason = archives.map(&:archiving_reason).join(", ")
    "#{'motif'.pluralize(archives.size)} d'archivage : #{reason}"
  end
end
