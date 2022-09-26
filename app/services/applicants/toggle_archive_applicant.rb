module Applicants
  class ToggleArchiveApplicant < BaseService
    def initialize(applicant:, rdv_solidarites_session:, archiving_reason:, archived_at:)
      @applicant = applicant
      @rdv_solidarites_session = rdv_solidarites_session
      @archiving_reason = archiving_reason
      @archived_at = archived_at
    end

    def call
      Applicant.transaction do
        update_applicant
        invalidate_invitations if @archived_at.nil?
      end
    end

    private

    def update_applicant
      @applicant.update(archiving_reason: @archiving_reason, archived_at: @archived_at)
    end

    def invalidate_invitations
      @applicant.invitations.each do |invitation|
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end
  end
end
