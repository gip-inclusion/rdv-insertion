module Notifications
  class NotifyApplicant < BaseService
    include Notifications::RdvConcern

    def initialize(applicant:, organisation:, rdv_solidarites_rdv:)
      @applicant = applicant
      @organisation = organisation
      @rdv_solidarites_rdv = rdv_solidarites_rdv
    end

    def call
      return if @applicant.phone_number.blank?

      check_applicant_organisation!
      notify_applicant
      update_notification_sent_at
    end

    protected

    def check_applicant_organisation!
      return if @applicant.organisation_ids.include?(@organisation.id)

      fail!("l'allocataire ne peut être invité car il n'appartient pas à l'organisation.")
    end

    def notify_applicant
      Notification.transaction do
        save_record!(notification)
        send_sms
      end
    end

    def phone_number_formatted
      @applicant.phone_number_formatted
    end

    def send_sms
      return Rails.logger.info(content) if Rails.env.development?

      call_service!(
        SendTransactionalSms,
        phone_number_formatted: phone_number_formatted, sender_name: sender_name, content: content
      )
    end

    def notification
      @notification ||= Notification.new(
        event: event,
        applicant: @applicant,
        rdv_solidarites_rdv_id: @rdv_solidarites_rdv.id
      )
    end

    def update_notification_sent_at
      notification.sent_at = Time.zone.now
      save_record!(notification)
    end

    def department
      @organisation.department
    end

    def sender_name
      "Dept#{department.number}"
    end
  end
end
