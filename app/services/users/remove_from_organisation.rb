module Users
  class RemoveFromOrganisation < BaseService
    def initialize(user:, organisation:, rdv_solidarites_session:)
      @user = user
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      User.transaction do
        @user.organisations.delete(@organisation)
        delete_rdv_solidarites_user_profile
        @user.soft_delete if @user.organisations.empty?
      end
    end

    private

    def delete_rdv_solidarites_user_profile
      @delete_rdv_solidarites_user_profile ||= call_service!(
        RdvSolidaritesApi::DeleteUserProfile,
        user_id: @user.rdv_solidarites_user_id,
        organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
