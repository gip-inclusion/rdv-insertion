module Applicants
  class RemoveFromOrganisation < BaseService
    def initialize(applicant:, organisation:, rdv_solidarites_session:)
      @applicant = applicant
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Applicant.transaction do
        @applicant.organisations.delete(@organisation)
        delete_rdv_solidarites_user_profile
        @applicant.soft_delete if @applicant.organisations.empty?
      end
    end

    private

    def delete_rdv_solidarites_user_profile
      @delete_rdv_solidarites_user_profile ||= call_service!(
        RdvSolidaritesApi::DeleteUserProfile,
        user_id: @applicant.rdv_solidarites_user_id,
        organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
