module InboundWebhooks
  module Brevo
    class AssignSmsDeliveryStatusAndDate < AssignDeliveryStatusAndDateBase
      private

      def delivery_status
        @delivery_status ||= @webhook_params[:msg_status]
      end

      def alert_sentry_if_webhook_mismatch
        return if @record.user.phone_number == PhoneNumberHelper.format_phone_number(@webhook_params[:to])

        Sentry.capture_message("#{record_class} mobile phone and webhook mobile phone does not match",
                               extra: { record: @record, webhook: @webhook_params })
      end
    end
  end
end
