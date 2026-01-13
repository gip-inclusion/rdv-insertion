module Brevo
  class MailWebhooksController < ApplicationController
    include Brevo::IpWhitelistConcern
    skip_before_action :authenticate_agent!, :verify_authenticity_token

    # High volume webhook rate limit: 1000 requests per minute
    rate_limit_with_json_response limit: 1000, period: 1.minute

    PERMITTED_PARAMS = %i[
      email
      event
      date
    ].freeze

    def create
      return if params[:"X-Mailin-custom"].nil?

      InboundWebhooks::Brevo::ProcessMailDeliveryStatusJob.perform_later(brevo_webhook_params, record_identifier)
    end

    private

    def record_identifier
      JSON.parse(params[:"X-Mailin-custom"])["record_identifier"]
    end

    def brevo_webhook_params
      params.permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
    end
  end
end
