module Invitations
  class AssignDeliveryStatusAndDate < BaseService
    def initialize(brevo_webhook_params:, invitation:)
      @brevo_webhook_params = brevo_webhook_params.deep_symbolize_keys
      @invitation = invitation
    end

    def call
      return if @invitation.delivery_status.in?(Invitation::FINAL_DELIVERY_STATUS)
      return if old_update?
      return if a_mail_webhook? && email_mismatch?
      return if a_sms_webhook? && phone_number_mismatch?

      Invitation.transaction do
        @invitation.delivery_status = delivery_status
        @invitation.delivery_status_received_at = @brevo_webhook_params[:date]
        save_record!(@invitation)
      end
    end

    private

    def delivery_status
      @delivery_status ||= if a_mail_webhook?
                             @brevo_webhook_params[:event]
                           elsif a_sms_webhook?
                             @brevo_webhook_params[:msg_status]
                           end
    end

    def old_update?
      return false if @invitation.delivery_status_received_at.blank?

      @invitation.delivery_status_received_at.to_datetime > @brevo_webhook_params[:date].to_datetime
    end

    def a_mail_webhook?
      @brevo_webhook_params[:email].present?
    end

    def a_sms_webhook?
      @brevo_webhook_params[:to].present?
    end

    def email_mismatch?
      return false if @invitation.email == @brevo_webhook_params[:email]

      Sentry.capture_message("Invitation email and webhook email does not match",
                             extra: { invitation: @invitation, webhook: @brevo_webhook_params })
    end

    def phone_number_mismatch?
      return false if @invitation.user.phone_number == PhoneNumberHelper.format_phone_number(@brevo_webhook_params[:to])

      Sentry.capture_message("Invitation mobile phone and webhook mobile phone does not match",
                             extra: { invitation: @invitation, webhook: @brevo_webhook_params })
    end
  end
end
