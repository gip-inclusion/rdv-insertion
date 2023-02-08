module Invitations
  class SendSms < BaseService
    include Invitations::SmsContent

    attr_reader :invitation

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
      if @invitation.reminder?
        send("#{invitation.template_model}_reminder_content")
      else
        send("#{@invitation.template_model}_content")
      end
    end
  end
end
