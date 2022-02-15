module Invitations
  class SaveAndSend < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      save_invitation_with_link
      unless @invitation.format_postal?
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

    def save_invitation_with_link
      call_service!(
        Invitations::SaveWithLink,
        invitation: @invitation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
