module InboundWebhooks
  module Brevo
    class AssignMailDeliveryStatusAndDate < AssignDeliveryStatusAndDateBase
      private

      def delivery_status
        @delivery_status ||= @webhook_params[:event]
      end
    end
  end
end
