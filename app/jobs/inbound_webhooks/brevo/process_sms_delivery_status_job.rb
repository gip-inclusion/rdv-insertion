module InboundWebhooks
  module Brevo
    class ProcessSmsDeliveryStatusJob < ProcessDeliveryStatusJobBase
      private

      def process_invitation
        Invitations::AssignSmsDeliveryStatusAndDate.call(webhook_params: @webhook_params,
                                                         invitation: @invitation)
      end
    end
  end
end
