module InboundWebhooks
  module Brevo
    class AssignDeliveryStatusAndDateBase < BaseService
      def initialize(webhook_params:, invitation:)
        @webhook_params = webhook_params.deep_symbolize_keys
        @invitation = invitation
      end

      def call
        return if @invitation.delivery_status.in?(Invitation::FINAL_DELIVERY_STATUS)
        return if old_update?
        return if webhook_mismatch?

        @invitation.delivery_status = delivery_status
        @invitation.delivered_at = @webhook_params[:date]
        save_record!(@invitation)
      end

      private

      def old_update?
        return false if @invitation.delivered_at.blank?

        @invitation.delivered_at.to_datetime > @webhook_params[:date].to_datetime
      end

      def webhook_mismatch?
        raise NoMethodError
      end

      def delivery_status
        raise NoMethodError
      end
    end
  end
end
