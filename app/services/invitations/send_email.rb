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
      @invitation.reminder? ? mailer_method_for_invitation_reminder : mailer_method_for_first_invitation
    end

    def mailer_method_for_first_invitation
      if InvitationMailer.respond_to?(:"invitation_for_#{motif_category}")
        :"invitation_for_#{motif_category}"
      elsif @invitation.for_atelier?
        :invitation_for_atelier
      else
        :regular_invitation
      end
    end

    def mailer_method_for_invitation_reminder
      if InvitationMailer.respond_to?(:"invitation_for_#{motif_category}_reminder")
        :"invitation_for_#{motif_category}_reminder"
      else
        :regular_invitation_reminder
      end
    end
  end
end
