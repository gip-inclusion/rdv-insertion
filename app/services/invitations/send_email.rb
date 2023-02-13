module Invitations
  class SendEmail < BaseService
    include Messengers::SendEmail

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      InvitationMailer.with(
        invitation: @invitation, applicant: @invitation.applicant
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

    def sendable
      @invitation
    end
  end
end
