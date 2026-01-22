module Brevo
  class SmsWebhooksController < ApplicationController
    include Brevo::IpWhitelistConcern
    skip_before_action :authenticate_agent!, :verify_authenticity_token

    rate_limit_with_json_response limit: RATE_LIMITS[:brevo_webhooks]

    PERMITTED_PARAMS = %i[
      to
      msg_status
      date
    ].freeze

    def create
      InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob.perform_later(brevo_webhook_params, record_identifier)
    end

    private

    def record_identifier
      params[:record_identifier]
    end

    def brevo_webhook_params
      params.permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
    end
  end
end
