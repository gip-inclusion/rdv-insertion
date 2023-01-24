module Invitations
  class SendSms < BaseService
    include Invitations::SmsContent

    attr_reader :invitation

    delegate :motif_category, :applicant, :help_phone_number, :number_of_days_to_accept_invitation,
             :number_of_days_before_expiration, :atelier?, :phone_platform?,
             to: :invitation

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      call_service!(
        Messengers::SendSms,
        sendable: @invitation,
        content: content
      )
    end

    private

    def content
      @invitation.reminder? ? compute_invitation_reminder_content : compute_invitation_content
    end

    def compute_invitation_reminder_content
      if phone_platform?
        content_for_phone_platform_reminder
      else
        regular_invitation_reminder_content
      end
    end

    def compute_invitation_content
      if atelier?
        content_for_atelier
      elsif phone_platform?
        content_for_phone_platform
      else
        regular_invitation_content
      end
    end
  end
end
