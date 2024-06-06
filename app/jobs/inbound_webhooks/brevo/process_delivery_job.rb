module InboundWebhooks
  module Brevo
    class ProcessDeliveryJob < ApplicationJob
      def perform(brevo_webhook_params, invitation_id)
        @brevo_webhook_params = brevo_webhook_params
        @invitation_id = invitation_id

        return unless invitation_present?

        Invitations::AssignDeliveryStatusAndDate.call(brevo_webhook_params: @brevo_webhook_params,
                                                      invitation: @invitation)
      end

      private

      def invitation
        @invitation ||= Invitation.find_by(id: @invitation_id)
      end

      def invitation_present?
        return true if invitation.present?

        Sentry.capture_message("Invitation not found", extra: { brevo_webhook_params: @brevo_webhook_params })
        false
      end
    end
  end
end
