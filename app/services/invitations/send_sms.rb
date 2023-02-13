module Invitations
  class SendSms < BaseService
    include Invitations::SmsContent
    include Messengers::SendSms

    attr_reader :invitation
    alias sendable invitation

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      send_sms
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
