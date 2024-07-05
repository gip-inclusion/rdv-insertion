module InboundWebhooks
  module Brevo
    class AssignDeliveryStatusAndDateBase < BaseService
      def initialize(webhook_params:, record:)
        @webhook_params = webhook_params.deep_symbolize_keys
        @record = record
      end

      def call
        set_last_brevo_webhook_received_at
        return unless delivery_status.in?(record_class.delivery_statuses.keys)
        return if webhook_mismatch?

        @record.delivery_status = delivery_status
        save_record!(@record)
      end

      private

      def set_last_brevo_webhook_received_at
        @record.last_brevo_webhook_received_at = @webhook_params[:date]
        save_record!(@record)
      end

      def record_class
        @record_class ||= @record.class
      end

      def webhook_mismatch?
        raise NoMethodError
      end

      def delivery_status
        raise NoMethodError
      end

      def delivered?
        delivery_status.in?(record_class::DELIVERED_STATUS)
      end
    end
  end
end
