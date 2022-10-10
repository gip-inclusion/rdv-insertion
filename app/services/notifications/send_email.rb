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
        applicant: @notification.applicant,
        rdv: rdv,
        signature_lines: @notification.signature_lines,
        motif_category: rdv.motif_category
      )
    end

    private

    def mailer_method
      if @notification.event == "rdv_cancelled"
        :rdv_cancelled
      elsif rdv.presential?
        :"presential_#{@notification.event}"
      elsif rdv.by_phone?
        :"by_phone_#{@notification.event}"
      else
        raise EmailNotificationError, "Message de convocation non géré pour le rdv #{rdv.id}"
      end
    end

    def rdv
      @notification.rdv
    end
  end
end
