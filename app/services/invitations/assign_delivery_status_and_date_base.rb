module Invitations
  class AssignDeliveryStatusAndDateBase < BaseService
    def initialize(webhook_params:, invitation:)
      @webhook_params = webhook_params.deep_symbolize_keys
      @invitation = invitation
    end

    def call
      return if @invitation.delivery_status.in?(Invitation::FINAL_DELIVERY_STATUS)
      return if old_update?
      return if webhook_mismatch?

      Invitation.transaction do
        @invitation.delivery_status = delivery_status
        @invitation.delivery_status_received_at = @webhook_params[:date]
        save_record!(@invitation)
      end
    end

    private

    def old_update?
      return false if @invitation.delivery_status_received_at.blank?

      @invitation.delivery_status_received_at.to_datetime > @webhook_params[:date].to_datetime
    end

    def webhook_mismatch?
      raise NoMethodError
    end

    def delivery_status
      raise NoMethodError
    end
  end
end
