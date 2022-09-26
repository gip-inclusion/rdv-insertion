module Applicants
  class ToggleArchiveApplicant < BaseService
    def initialize(applicant:, rdv_solidarites_session:, archiving_reason:, archived_at:)
      @applicant = applicant
      @rdv_solidarites_session = rdv_solidarites_session
      @archiving_reason = archiving_reason
      @archived_at = archived_at
    end

    def call
      update_applicant
      invalidate_invitations if @archived_at.present?
    end

    private

    def update_applicant
      @applicant.assign_attributes(archiving_reason: @archiving_reason, archived_at: @archived_at)
      save_record!(@applicant)
    end

    def invalidate_invitations
      @applicant.invitations.each do |invitation|
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end
  end
end
