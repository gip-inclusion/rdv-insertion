module RdvSolidaritesApi
  class UpdateWebhookEndpoint < Base
    def initialize(
      rdv_solidarites_webhook_endpoint_id:,
      rdv_solidarites_organisation_id:,
      rdv_solidarites_session:,
      subscriptions: WebhookEndpoint::ALL_SUBSCRIPTIONS
    )
      @rdv_solidarites_webhook_endpoint_id = rdv_solidarites_webhook_endpoint_id
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
      @rdv_solidarites_session = rdv_solidarites_session
      @subscriptions = subscriptions
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_webhook_endpoint(
        @rdv_solidarites_webhook_endpoint_id, @rdv_solidarites_organisation_id, @subscriptions
      )
    end
  end
end
