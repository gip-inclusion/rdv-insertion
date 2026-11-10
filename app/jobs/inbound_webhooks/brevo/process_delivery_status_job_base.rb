module InboundWebhooks
  module Brevo
    class ProcessDeliveryStatusJobBase < ApplicationJob
      RECORD_CLASSES = { "invitation" => Invitation, "notification" => Notification }.freeze

      def perform(webhook_params, record_identifier)
        @webhook_params = webhook_params
        @record_identifier = record_identifier

        return unless record_present?

        assign_delivery_status_and_date
      end

      private

      def assign_delivery_status_and_date
        raise NoMethodError
      end

      def record
        # record_identifier : notification_123 or invitation_123
        @record ||= RECORD_CLASSES[record_type]&.find_by(id: record_id)
      end

      def record_type
        @record_type ||= @record_identifier.split("_").first
      end

      def record_id
        @record_id ||= @record_identifier.split("_").last
      end

      def record_present?
        return true if record.present?

        Sentry.capture_message("#{record_type.classify} not found", extra: { webhook_params: @webhook_params })
        false
      end
    end
  end
end
