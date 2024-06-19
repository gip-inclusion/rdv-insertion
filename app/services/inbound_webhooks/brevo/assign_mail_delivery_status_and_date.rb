module InboundWebhooks
  module Brevo
    class AssignMailDeliveryStatusAndDate < AssignDeliveryStatusAndDateBase
      private

      def delivery_status
        @delivery_status ||= @webhook_params[:event]
      end

      def webhook_mismatch?
        return false if @invitation.email == @webhook_params[:email]

        Sentry.capture_message("Invitation email and webhook email does not match",
                               extra: { invitation: @invitation, webhook: @webhook_params })
        true
      end
    end
  end
end
