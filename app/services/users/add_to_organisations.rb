module Users
  class AddToOrganisations < BaseService
    def initialize(user:, organisations:)
      @user = user
      @organisations = organisations
    end

    def call
      UsersOrganisation.transaction do
        @user.organisations |= @organisations

        call_service!(
          RdvSolidaritesApi::CreateUserProfiles,
          rdv_solidarites_user_id: @user.rdv_solidarites_user_id,
          rdv_solidarites_organisation_ids: @organisations.map(&:rdv_solidarites_organisation_id)
        )
      end
    end
  end
end
