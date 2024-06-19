module InboundWebhooks
  module Brevo
    class ProcessDeliveryStatusJobBase < ApplicationJob
      def perform(webhook_params, invitation_id)
        @webhook_params = webhook_params
        @invitation_id = invitation_id

        return unless invitation_present?

        assign_delivery_status_and_date
      end

      private

      def assign_delivery_status_and_date
        raise NoMethodError
      end

      def invitation
        @invitation ||= Invitation.find_by(id: @invitation_id)
      end

      def invitation_present?
        return true if invitation.present?

        Sentry.capture_message("Invitation not found", extra: { webhook_params: @webhook_params })
        false
      end
    end
  end
end
