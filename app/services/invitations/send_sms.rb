module Invitations
  class SendSms < BaseService
    include Invitations::SmsContent

    attr_reader :invitation

    delegate :motif_category, :applicant, :help_phone_number, :number_of_days_to_accept_invitation,
             :number_of_days_before_expiration, :for_atelier?,
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
      # unless the message is specific for the category we send the regular reminder content
      if respond_to?(:"content_for_#{motif_category}_reminder", true)
        send(:"content_for_#{motif_category}_reminder")
      else
        regular_invitation_reminder_content
      end
    end

    def compute_invitation_content
      # unless the messsage is specific for the category we send the regular content
      if respond_to?(:"content_for_#{motif_category}", true)
        send(:"content_for_#{motif_category}")
      elsif for_atelier?
        content_for_atelier
      else
        regular_invitation_content
      end
    end
  end
end
