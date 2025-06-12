module FranceTravailApi
  class CreateParticipation < BaseService
    # https://francetravail.io/data/api/rechercher-usager/rdv-partenaire/documentation#/api-reference/
    include Webhooks::ReceiptHandler

    def initialize(participation:, timestamp:)
      @participation = participation
      @timestamp = timestamp
    end

    def call
      with_webhook_receipt(
        resource_model: "Participation",
        resource_id: @participation.id,
        timestamp: @timestamp
      ) do
        send_create_request!
      end
    end

    private

    def send_create_request!
      response = FranceTravailClient.create_participation(
        payload: @participation.to_ft_payload,
        headers: ft_user_headers
      )

      response_body = response.body.force_encoding("UTF-8")

      if response.success? && JSON.parse(response_body)["id"].present?
        @participation.update_column(:france_travail_id, JSON.parse(response_body)["id"])
      else
        handle_failure!(response)
      end

      response
    end

    def handle_failure!(response)
      response_body = response.body.force_encoding("UTF-8")
      fail!(
        "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Création de Participation).\n" \
        "Status: #{response.status}\n Body: #{response_body}"
      )
    end

    def ft_user_headers
      call_service!(BuildUserAuthenticatedHeaders, user: @participation.user).headers
    end
  end
end
