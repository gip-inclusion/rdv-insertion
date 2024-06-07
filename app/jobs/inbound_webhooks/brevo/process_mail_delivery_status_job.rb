module InboundWebhooks
  module Brevo
    class ProcessMailDeliveryStatusJob < ProcessDeliveryStatusJobBase
      private

      def process_invitation
        Invitations::AssignMailDeliveryStatusAndDate.call(webhook_params: @webhook_params,
                                                          invitation: @invitation)
      end
    end
  end
end
