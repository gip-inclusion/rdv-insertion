module InboundWebhooks
  module Brevo
    class AssignSmsDeliveryStatusAndDate < AssignDeliveryStatusAndDateBase
      private

      def delivery_status
        @delivery_status ||= @webhook_params[:msg_status]
      end
    end
  end
end
