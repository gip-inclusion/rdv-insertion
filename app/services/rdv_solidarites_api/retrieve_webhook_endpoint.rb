module RdvSolidaritesApi
  class RetrieveWebhookEndpoint < Base
    def initialize(rdv_solidarites_organisation_id:)
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    end

    def call
      request!
      result.webhook_endpoint = rdv_solidarites_webhook_endpoint
    end

    private

    def rdv_solidarites_webhook_endpoint
      return if rdv_solidarites_response_body["webhook_endpoints"].blank?

      RdvSolidarites::WebhookEndpoint.new(rdv_solidarites_response_body["webhook_endpoints"][0])
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_webhook_endpoint(@rdv_solidarites_organisation_id)
    end
  end
end
