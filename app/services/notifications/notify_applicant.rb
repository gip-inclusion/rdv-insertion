module Notifications
  class NotifyApplicant < BaseService
    include Notifications::RdvConcern

    def initialize(applicant:, rdv_solidarites_rdv:)
      @applicant = applicant
      @rdv_solidarites_rdv = rdv_solidarites_rdv
    end

    def call
      check_phone_number!
      notify_applicant!
      update_notification_sent_at!
    end

    protected

    def check_phone_number!
      fail!("le téléphone n'est pas renseigné") if phone_number.blank?
    end

    def notify_applicant!
      fail! unless notify_applicant
    end

    def notify_applicant
      Notification.transaction do
        save_notification
        raise ActiveRecord::Rollback if failed?

        send_sms
        raise ActiveRecord::Rollback if failed?

        true
      end
    end

    def save_notification
      return if notification.save

      result.errors << notification.errors.full_messages.to_sentence
    end

    def phone_number
      @applicant.phone_number_formatted
    end

    def send_sms
      Rails.logger.info(content)
      return if Rails.env.development?
      return if send_sms_service.success?

      result.errors += send_sms_service.errors
    end

    def send_sms_service
      @send_sms_service ||= SendTransactionalSms.call(phone_number: phone_number, content: content)
    end

    def notification
      @notification || Notification.new(
        event: event,
        applicant: @applicant,
        rdv_solidarites_rdv_id: @rdv_solidarites_rdv.id
      )
    end

    def update_notification_sent_at!
      return if notification.update(sent_at: Time.zone.now)

      result.errors << notification.errors.full_messages.to_sentence
      fail!
    end
  end
end
