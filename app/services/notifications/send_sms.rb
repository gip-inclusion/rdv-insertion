class SmsNotificationError < StandardError; end

module Notifications
  class SendSms < BaseService
    include Notifications::SmsContent
    include Messengers::SendSms

    attr_reader :notification

    def initialize(notification:)
      @notification = notification
    end

    def call
      verify_format!(notification)
      verify_phone_number!(notification)
      send_sms(notification.sms_sender_name, notification.phone_number, content)
    end

    private

    def content
      send(content_method_name)
    end

    def content_method_name
      if @notification.event == "participation_cancelled"
        :content_for_participation_cancelled
      elsif @notification.rdv.presential?
        :"presential_content_for_#{@notification.event}"
      elsif @notification.rdv.by_phone?
        :"by_phone_content_for_#{@notification.event}"
      else
        raise SmsNotificationError, "Message de convocation non géré pour le rdv #{@notification.rdv.id}"
      end
    end
  end
end
