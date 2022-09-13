module Invitations
  class SaveAndSend < BaseService
    def initialize(invitation:, rdv_solidarites_session: nil)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Invitation.with_advisory_lock "invite_applicant_#{applicant.id}" do
        assign_link_and_token
        save_record!(@invitation)
        send_invitation
        update_invitation_sent_at
      end
      result.invitation = @invitation
    end

    private

    def update_invitation_sent_at
      @invitation.sent_at = Time.zone.now
      save_record!(@invitation)
    end

    def send_invitation
      send_to_applicant = @invitation.send_to_applicant
      return if send_to_applicant.success?

      result.errors += send_to_applicant.errors
      fail!
    end

    def assign_link_and_token
      return if @invitation.link? && @invitation.token?

      call_service!(
        Invitations::AssignAttributes,
        invitation: @invitation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def applicant
      @invitation.applicant
    end
  end
end
