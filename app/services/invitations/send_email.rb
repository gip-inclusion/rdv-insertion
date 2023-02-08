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
        :"#{@invitation.template_model}_invitation_reminder"
      else
        :"#{@invitation.template_model}_invitation"
      end
    end
  end
end
