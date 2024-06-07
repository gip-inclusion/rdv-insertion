module InboundWebhooks
  module Brevo
    class ProcessDeliveryStatusJobBase < ApplicationJob
      def perform(webhook_params, invitation_id)
        @webhook_params = webhook_params
        @invitation_id = invitation_id

        return unless invitation_present?

        process_invitation
      end

      private

      def process_invitation
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
