module Invitations
  class AssignSmsDeliveryStatusAndDate < AssignDeliveryStatusAndDateBase
    private

    def delivery_status
      @delivery_status ||= @webhook_params[:msg_status]
    end

    def webhook_mismatch?
      return false if @invitation.user.phone_number == PhoneNumberHelper.format_phone_number(@webhook_params[:to])

      Sentry.capture_message("Invitation mobile phone and webhook mobile phone does not match",
                             extra: { invitation: @invitation, webhook: @webhook_params })
      true
    end
  end
end
