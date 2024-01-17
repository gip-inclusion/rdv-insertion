module RdvSolidaritesApi
  class CreateWebhookEndpoint < Base
    def initialize(
      rdv_solidarites_organisation_id:,
      subscriptions: RdvSolidarites::WebhookEndpoint::ALL_SUBSCRIPTIONS,
      trigger: false
    )
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
      @subscriptions = subscriptions
      @trigger = trigger
    end

    def call
      request!
      result.webhook_endpoint_id = rdv_solidarites_response_body["webhook_endpoint"]["id"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.create_webhook_endpoint(@rdv_solidarites_organisation_id, @subscriptions, @trigger)
    end
  end
end
