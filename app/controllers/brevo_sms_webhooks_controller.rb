class BrevoSmsWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!, :verify_authenticity_token

  PERMITTED_PARAMS = %i[
    to
    msg_status
    date
  ].freeze

  def create
    Invitations::AssignDeliveryStatusAndDate.call(brevo_webhook_params: brevo_webhook_params,
                                                  invitation_id: params[:invitation_id])
  end

  private

  def brevo_webhook_params
    params.permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end
end