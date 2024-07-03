module ArchivesHelper
  def archived_scope?(scope)
    scope == "archived"
  end

  def archive_for(organisation, archives)
    archives.find { |archive| archive.organisation_id == organisation.id }
  end

  def user_archived_in?(user, structure, structure_type)
    return user.archive_for(structure).present? if structure_type == "organisation"

    user_department_archives(user).count == current_agent_department_organisations.count
  end

  def user_department_archives(user)
    user.archives.select do |archive|
      current_agent_department_organisations.map(&:id).include?(archive.organisation_id)
    end
  end
end
