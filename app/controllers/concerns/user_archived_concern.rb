module UserArchivedConcern
  extend ActiveSupport::Concern

  private

  def set_user_is_archived
    @user_is_archived =
      @user.archives.where(organisation: user_agent_department_organisations).count ==
      user_agent_department_organisations.count
    return unless @user_is_archived

    archived_organisations = @user.archives.map(&:organisation)
    archived_organisations_names = archived_organisations.map(&:name).join(", ")

    organisation_count = archived_organisations.size
    organisation_wording = organisation_count > 1 ? "les organisations" : "l'organisation"

    @archived_banner_content = {
      title: "Dossier archivé",
      description: "Ce bénéficiaire est archivé sur #{organisation_wording} #{archived_organisations_names}",
      persist: true
    }
  end

  def user_agent_department_organisations
    @user_agent_department_organisations ||= @user.organisations & @current_organisations
  end
end
