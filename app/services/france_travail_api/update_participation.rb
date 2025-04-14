module FranceTravailApi
  class UpdateParticipation < BaseService
    # https://francetravail.io/data/api/rechercher-usager/rdv-partenaire/documentation#/api-reference/
    include Webhooks::ReceiptHandler

    def initialize(participation_id:, timestamp:)
      @participation = Participation.find(participation_id)
      @timestamp = timestamp
    end

    def call
      with_webhook_receipt(
        resource_model: "Participation",
        resource_id: @participation.id,
        timestamp: @timestamp
      ) do
        send_update_request!
      end
    end

    private

    def send_update_request!
      response = FranceTravailClient.update_participation(
        payload: @participation.to_ft_payload,
        headers: ft_user_headers
      )

      handle_failure!(response) unless response.success?
      response
    end

    def handle_failure!(response)
      fail!(
        "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Update de Participation).\n" \
        "Status: #{response.status}\n Body: #{response.body.force_encoding('UTF-8')}"
      )
    end

    def ft_user_headers
      call_service!(BuildUserAuthenticatedHeaders, user: @participation.user).headers
    end
  end
end
