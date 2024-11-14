module Users
  class RemoveFromOrganisation < BaseService
    def initialize(user:, organisation:)
      @user = user
      @organisation = organisation
    end

    def call
      User.transaction do
        @user.organisations.delete(@organisation)
        delete_rdv_solidarites_user_profile if @user.rdv_solidarites_user_id.present?
        @user.soft_delete if @user.organisations.empty?
      end

      CleanUnusedFollowUpsJob.perform_later(@user.id)
    end

    private

    def delete_rdv_solidarites_user_profile
      @delete_rdv_solidarites_user_profile ||= call_service!(
        RdvSolidaritesApi::DeleteUserProfile,
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      )
    end
  end
end
