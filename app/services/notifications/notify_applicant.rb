module Notifications
  class NotifyApplicant < BaseService
    include Notifications::RdvConcern

    def initialize(applicant:, organisation:, rdv_solidarites_rdv:)
      @applicant = applicant
      @organisation = organisation
      @rdv_solidarites_rdv = rdv_solidarites_rdv
    end

    def call
      return if phone_number.blank?

      check_applicant_organisation!
      notify_applicant!
      update_notification_sent_at!
    end

    protected

    def check_applicant_organisation!
      return if @applicant.organisation_ids.include?(@organisation.id)

      fail!("l'allocataire ne peut être invité car il n'appartient pas à l'organisation.")
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
      @applicant.phone_number
    end

    def send_sms!
      return Rails.logger.info(content) if Rails.env.development?
      return if send_sms.success?

      result.errors += send_sms.errors
      fail!
    end

    def send_sms
      @send_sms ||= SendTransactionalSms.call(phone_number: phone_number, sender_name: sender_name, content: content)
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

    def department
      @organisation.department
    end

    def sender_name
      "Dept#{department.number}"
    end
  end
end
