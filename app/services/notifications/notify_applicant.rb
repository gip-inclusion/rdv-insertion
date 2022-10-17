module Notifications
  class NotifyApplicant < BaseService
    def initialize(rdv:, applicant:, event:, format:)
      @rdv = rdv
      @applicant = applicant
      @event = event
      @format = format
    end

    def call
      Notification.transaction do
        save_record!(notification)
        send_notification
      end
      update_notification_sent_at
    end

    private

    def notification
      @notification ||= Notification.new(
        rdv: @rdv,
        applicant: @applicant,
        event: @event,
        format: @format,
        # needed in case the rdv gets deleted
        rdv_solidarites_rdv_id: @rdv.rdv_solidarites_rdv_id
      )
    end

    def send_notification
      send_to_applicant = @notification.send_to_applicant
      return if send_to_applicant.success?

      result.errors += send_to_applicant.errors
      fail!
    end

    def update_notification_sent_at
      notification.sent_at = Time.zone.now
      save_record!(notification)
    end
  end
end
