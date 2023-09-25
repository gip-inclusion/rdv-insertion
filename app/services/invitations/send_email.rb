module Invitations
  class SendEmail < BaseService
    include Messengers::SendEmail

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      verify_format!(@invitation)
      verify_email!(@invitation)

      InvitationMailer.with(
        invitation: @invitation, user: @invitation.user
      ).send(mailer_method).deliver_now
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
