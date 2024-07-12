module ArchivesHelper
  def archived_scope?(scope)
    scope == "archived"
  end

  def archive_for(organisation, archives)
    archives.find { |archive| archive.organisation_id == (organisation.id || current_organisation.id) }
  end

  def user_archived_in?(user, structure)
    return user.organisation_archives(structure).present? if structure.is_a?(Organisation)

    user_department_archives(user).count == user_agent_department_organisations(user).count
  end

  def user_agent_department_organisations(user)
    user.organisations & current_agent_department_organisations
  end

  def user_department_archives(user)
    user.archives.select do |archive|
      current_agent_department_organisations.map(&:id).include?(archive.organisation_id)
    end
  end
end
