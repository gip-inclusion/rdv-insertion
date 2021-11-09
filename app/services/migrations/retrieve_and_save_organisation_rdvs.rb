module Migrations
  class RetrieveAndSaveOrganisationRdvs < BaseService
    def initialize(organisation_id:, rdv_solidarites_session:)
      @organisation_id = organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      retrieve_rdv_solidarites_rdvs!
      upsert_rdvs
    end

    private

    def upsert_rdvs
      rdv_solidarites_rdvs.each do |rdv|
        applicant_ids = retrieve_applicants_ids(rdv.user_ids)
        # if it is not linked to a RDVI applicant we do not save the rdv
        next if applicant_ids.empty?

        UpsertRdvJob.perform_async(rdv.attributes, applicant_ids, organisation.id)
      end
    end

    def retrieve_applicants_ids(user_ids)
      Applicant.where(rdv_solidarites_user_id: user_ids, organisation_id: organisation.id).pluck(:id)
    end

    def retrieve_rdv_solidarites_rdvs!
      return if retrieve_rdv_solidarites_rdvs.success?

      result.errors += retrieve_rdv_solidarites_rdvs.errors
      fail!
    end

    def rdv_solidarites_rdvs
      retrieve_rdv_solidarites_rdvs.rdvs
    end

    def organisation
      @organisation ||= Organisation.includes(:applicants).find_by!(rdv_solidarites_organisation_id: @organisation_id)
    end

    def retrieve_rdv_solidarites_rdvs
      @retrieve_rdv_solidarites_rdvs ||= RdvSolidaritesApi::RetrieveResources.call(
        rdv_solidarites_session: @rdv_solidarites_session,
        organisation_id: @organisation_id,
        resource_name: "rdvs"
      )
    end
  end
end
