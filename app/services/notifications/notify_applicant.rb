module Notifications
  class NotifyApplicant < BaseService
    include Notifications::RdvConcern

    def initialize(applicant:, department:, rdv_solidarites_rdv:)
      @applicant = applicant
      @department = department
      @rdv_solidarites_rdv = rdv_solidarites_rdv
    end

    def call
      check_applicant_department!
      check_phone_number!
      notify_applicant!
      update_notification_sent_at!
    end

    protected

    def check_applicant_department!
      return if @applicant.department_ids.include?(@department.id)

      fail!("l'allocataire ne peut être invité car il n'appartient pas à l'organisation.")
    end

    def check_phone_number!
      fail!("le téléphone n'est pas renseigné") if phone_number.blank?
    end

    def notify_applicant!
      Notification.transaction do
        save_notification!
        send_sms!
      end
    end

    def save_notification!
      return if notification.save

      result.errors << notification.errors.full_messages.to_sentence
      fail!
    end

    def phone_number
      @applicant.phone_number_formatted
    end

    def send_sms!
      return Rails.logger.info(content) if Rails.env.development?
      return if send_sms.success?

      result.errors += send_sms.errors
      fail!
    end

    def send_sms
      @send_sms ||= SendTransactionalSms.call(phone_number: phone_number, content: content)
    end

    def notification
      @notification || Notification.find_or_initialize_by(
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
