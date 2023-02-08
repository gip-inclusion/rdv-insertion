class EmailNotificationError < StandardError; end

module Notifications
  class SendEmail < BaseService
    def initialize(notification:)
      @notification = notification
    end

    def call
      call_service!(
        Messengers::SendEmail,
        sendable: @notification,
        mailer_class: NotificationMailer,
        mailer_method: mailer_method,
        notification: @notification
      )
    end

    private

    def mailer_method
      if @notification.event == "participation_cancelled"
        :participation_cancelled
      elsif @notification.rdv.presential?
        :"presential_#{@notification.event}"
      elsif @notification.rdv.by_phone?
        :"by_phone_#{@notification.event}"
      else
        raise EmailNotificationError, "Message de convocation non géré pour le rdv #{@notification.rdv.id}"
      end
    end
  end
end
