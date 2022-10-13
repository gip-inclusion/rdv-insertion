module Invitations
  class SendEmail < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      call_service!(
        Messengers::SendEmail,
        sendable: @invitation,
        mailer_class: InvitationMailer,
        mailer_method: mailer_method,
        invitation: @invitation,
        applicant: @invitation.applicant
      )
    end

    private

    def mailer_method
      if @invitation.reminder?
        :"invitation_for_#{@invitation.motif_category}_reminder"
      else
        :"invitation_for_#{@invitation.motif_category}"
      end
    end
  end
end
