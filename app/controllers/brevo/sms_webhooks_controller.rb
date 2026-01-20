module Brevo
  class SmsWebhooksController < ApplicationController
    include Brevo::IpWhitelistConcern
    skip_before_action :authenticate_agent!, :verify_authenticity_token

    # High volume webhook rate limit: 1000 requests per minute
    rate_limit_with_json_response limit: ENV.fetch("RATE_LIMIT_BREVO_SMS_WEBHOOKS", ENV["RATE_LIMIT_DEFAULT"]).to_i,
                                  period: 1.minute

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
