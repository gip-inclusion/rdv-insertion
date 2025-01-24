module InboundWebhooks
  module Brevo
    class AssignDeliveryStatusAndDateBase < BaseService
      def initialize(webhook_params:, record:)
        @webhook_params = webhook_params.deep_symbolize_keys
        @record = record
      end

      def call
        return if old_update?
        return if @record.delivered?

        set_last_brevo_webhook_received_at
        return unless delivery_status.in?(record_class.delivery_statuses.keys)

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

      def delivery_status
        raise NoMethodError
      end

      def old_update?
        return false if @record.last_brevo_webhook_received_at.blank?

        record_datetime = @record.last_brevo_webhook_received_at
        webhook_datetime = Time.zone.parse(@webhook_params[:date].to_s)

        record_datetime > webhook_datetime
      end
    end
  end
end
