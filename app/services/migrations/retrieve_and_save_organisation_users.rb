module Migrations
  class RetrieveAndSaveOrganisationUsers < Migrations::Base
    alias rdv_solidarites_users rdv_solidarites_resources

    def call
      super
      upsert_users
      soft_delete_users
    end

    private

    def upsert_users
      rdv_solidarites_users.each do |user|
        applicant = Applicant.includes(:organisations).find_by(rdv_solidarites_user_id: user.id)

        next if applicant.nil?

        UpsertRecordJob.perform_async(Applicant, user.attributes)
      end
    end

    def soft_delete_users
      organisation.applicants.find_each do |applicant|
        rdv_solidarites_user = rdv_solidarites_users.find { _1.id == applicant.rdv_solidarites_user_id }
        next if rdv_solidarites_user

        if applicant.organisations.length > 1
          applicant.delete_organisation(organisation)
        else
          SoftDeleteApplicantJob.perform_async(rdv_solidarites_user.id)
        end
      end
    end
  end
end
