module Invitations
  class SaveAndSend < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      save_invitation!
      send_invitation!
      update_invitation_sent_at!
      result.invitation = @invitation
    end

    private

    def update_invitation_sent_at!
      @invitation.sent_at = Time.zone.now
      save_record!(@invitation)
    end

    def send_invitation!
      return if send_invitation.success?

      result.errors += send_invitation.errors
      fail!
    end

    def send_invitation
      @send_invitation ||= @invitation.send_to_applicant
    end

    def save_invitation!
      call_service!(
        Invitations::Save,
        invitation: @invitation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
