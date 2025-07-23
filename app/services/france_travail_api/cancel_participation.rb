module FranceTravailApi
  class CancelParticipation < BaseService
    # https://francetravail.io/data/api/rechercher-usager/rdv-partenaire/documentation#/api-reference/
    include Webhooks::ReceiptHandler

    def initialize(participation_id:, france_travail_id:, user:, timestamp:)
      @participation_id = participation_id
      @france_travail_id = france_travail_id
      @user = user
      @timestamp = timestamp
    end

    def call
      with_webhook_receipt(
        resource_model: "Participation",
        resource_id: @participation_id,
        timestamp: @timestamp
      ) do
        send_request!
      end
    end

    private

    def send_request!
      response = FranceTravailClient.cancel_participation(
        france_travail_id: @france_travail_id,
        headers: ft_user_headers
      )

      handle_failure!(response) unless response.success?
    end

    def handle_failure!(response)
      fail!(
        "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Suppression de Participation).\n" \
        "Status: #{response.status}\n Body: #{response.body.force_encoding('UTF-8')}"
      )
    end

    def ft_user_headers
      call_service!(BuildUserAuthenticatedHeaders, user: @user).headers
    end
  end
end
