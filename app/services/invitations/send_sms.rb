module Invitations
  class SendSms < BaseService
    include Invitations::SmsContent

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
        send(:"content_for_#{@invitation.motif_category}_reminder")
      else
        send(:"content_for_#{@invitation.motif_category}")
      end
    end
  end
end
