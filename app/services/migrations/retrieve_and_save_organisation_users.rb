module Migrations
  class RetrieveAndSaveOrganisationUsers < Migrations::Base
    alias rdv_solidarites_users rdv_solidarites_resources

    def call
      super
      upsert_users
      remove_deleted_users
    end

    private

    def upsert_users
      rdv_solidarites_users.each do |user|
        applicant = Applicant.includes(:organisations).find_by(rdv_solidarites_user_id: user.id)

        next if applicant.nil?

        UpsertRecordJob.perform_async(Applicant, user.attributes)
      end
    end

    # rubocop:disable Metrics/AbcSize, Rails/Output
    def remove_deleted_users
      organisation.applicants.find_each do |applicant|
        rdv_solidarites_user = rdv_solidarites_users.find { _1.id == applicant.rdv_solidarites_user_id }
        next if rdv_solidarites_user

        puts "Applicant #{applicant.id} not found found in RDV Solidarites for "\
             "organisation #{@organisation_id}. Deleting? (y/n)"
        response = gets.chomp&.downcase

        next unless response.in?(%w[y yes])

        applicant.delete_organisation(organisation)
        DeleteApplicantJob.perform_async(applicant.rdv_solidarites_user_id) if applicant.organisations.empty?
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/Output
  end
end
