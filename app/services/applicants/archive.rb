module Applicants
  class Archive < BaseService
    def initialize(applicant:, rdv_solidarites_session:, archiving_reason:)
      @applicant = applicant
      @rdv_solidarites_session = rdv_solidarites_session
      @archiving_reason = archiving_reason
    end

    def call
      Applicant.transaction do
        archive_applicant
        @applicant.invalidate_invitations
      end
    end

    private

    def archive_applicant
      @applicant.assign_attributes(archiving_reason: @archiving_reason, archived_at: Time.zone.now)
      save_record!(@applicant)
    end
  end
end
