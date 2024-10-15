module UserArchivedConcern
  extend ActiveSupport::Concern

  private

  def set_user_is_archived
    @user_is_archived =
      @user.archives.where(organisation: user_agent_department_organisations).count ==
      user_agent_department_organisations.count
    return unless @user_is_archived

    archived_organisations_names = @user.archives.map(&:organisation).map(&:name).join(", ")
    @archived_message =
      FlashMessage.new(
        title: "Dossier archivé",
        description: "Ce bénéficiaire est archivé sur les organisations #{archived_organisations_names}",
        persist: true
      )
  end

  def user_agent_department_organisations
    @user_agent_department_organisations ||= @user.organisations & @current_organisations
  end
end
