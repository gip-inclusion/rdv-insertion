module RdvSolidaritesApi
  class CreateWebhookEndpoint < Base
    def initialize(rdv_solidarites_organisation_id:, rdv_solidarites_session:)
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
      result.webhook_endpoint = \
        RdvSolidarites::WebhookEndpoint.new(rdv_solidarites_response_body["webhook_endpoint"])
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_webhook_endpoint(webhook_endpoint_attributes)
    end

    def webhook_endpoint_attributes
      @webhook_endpoint_attributes ||= {
        organisation_id: @rdv_solidarites_organisation_id,
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
        secret: ENV["RDV_SOLIDARITES_SECRET"],
        subscriptions: %w[rdv user user_profile organisation motif lieu agent agent_role referent_assignation]
      }
    end
  end
end
