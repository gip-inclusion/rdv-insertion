module Users
  class ArchivedStatus < BaseService
    def initialize(user:, organisations:)
      @user = user
      @organisations = organisations
    end

    def call
      result.is_archived = archived?
      result.archived_banner_content = archived_banner_content if archived?
    end

    private

    def archived?
      archived_user = @user.archives.where(organisation: user_agent_department_organisations).count ==
                      user_agent_department_organisations.count
      return false unless archived_user

      true
    end

    def archived_banner_content
      return nil unless archived?

      archived_organisations = @user.archives.map(&:organisation)
      archived_organisations_names = archived_organisations.map(&:name).join(", ")

      organisation_count = archived_organisations.size
      organisation_wording = organisation_count > 1 ? "les organisations" : "l'organisation"

      {
        title: "Dossier archivé",
        description: "Ce bénéficiaire est archivé sur #{organisation_wording} #{archived_organisations_names}",
        persist: true
      }
    end

    def user_agent_department_organisations
      @user.organisations & @organisations
    end
  end
end
