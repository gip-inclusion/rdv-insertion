class SmsNotificationError < StandardError; end

module Notifications
  class SendSms < BaseService
    include Notifications::SmsContent

    def initialize(notification:)
      @notification = notification
    end

    def call
      call_service!(
        Messengers::SendSms,
        sendable: @notification,
        content: content
      )
    end

    private

    def rdv
      @notification.rdv
    end

    def content
      send(content_method_name)
    end

    def content_method_name
      if @notification.event == "rdv_cancelled"
        :content_for_rdv_cancelled
      elsif rdv.presential?
        :"presential_content_for_#{@notification.event}"
      elsif rdv.by_phone?
        :"by_phone_content_for_#{@notification.event}"
      else
        raise SmsNotificationError, "Message de convocation non géré pour le rdv #{rdv.id}"
      end
    end
  end
end
