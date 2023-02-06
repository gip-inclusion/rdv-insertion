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

    def motif_category
      @invitation.motif_category
    end

    def mailer_method
      @invitation.reminder? ? mailer_method_for_invitation_reminder : mailer_method_for_manual_invitation
    end

    def mailer_method_for_manual_invitation
      if @invitation.atelier?
        :invitation_for_atelier
      elsif @invitation.phone_platform?
        :invitation_for_phone_platform
      else
        :regular_invitation
      end
    end

    def mailer_method_for_invitation_reminder
      if @invitation.phone_platform?
        :invitation_for_phone_platform_reminder
      else
        :regular_invitation_reminder
      end
    end
  end
end
