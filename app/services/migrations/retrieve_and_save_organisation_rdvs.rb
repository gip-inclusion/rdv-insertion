module Migrations
  class RetrieveAndSaveOrganisationRdvs < Migrations::Base
    alias rdv_solidarites_rdvs rdv_solidarites_resources

    def call
      super
      upsert_rdvs
    end

    private

    def upsert_rdvs
      rdv_solidarites_rdvs.each do |rdv|
        applicant_ids = retrieve_applicants_ids(rdv.user_ids)
        # if it is not linked to a RDVI applicant we do not save the rdv
        next if applicant_ids.empty?

        UpsertRecordJob.perform_async(
          Rdv,
          rdv.attributes,
          { applicant_ids: applicant_ids, organisation_id: @organisation_id }
        )
      end
    end

    def retrieve_applicants_ids(user_ids)
      Applicant.where(rdv_solidarites_user_id: user_ids).pluck(:id)
    end
  end
end
