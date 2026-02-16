class EmailNotificationError < StandardError; end

module Notifications
  class SendEmail < BaseService
    include Messengers::SendEmail
    include Notifications::SenderPhoneNumberValidation

    def initialize(notification:)
      @notification = notification
    end

    def call
      verify_format!(@notification)
      verify_sender_phone_number!(@notification)
      verify_email!(@notification)

      NotificationMailer.with(
        notification: @notification
      ).send(mailer_method).deliver_now
    end

    private

    def mailer_method
      if @notification.event == "participation_cancelled"
        :participation_cancelled
      elsif @notification.rdv.presential?
        :"presential_#{@notification.event}"
      elsif @notification.rdv.by_phone?
        :"by_phone_#{@notification.event}"
      elsif @notification.rdv.visio?
        :"visio_#{@notification.event}"
      else
        raise EmailNotificationError, "Message de convocation non géré pour le rdv #{@notification.rdv.id}"
      end
    end
  end
end
