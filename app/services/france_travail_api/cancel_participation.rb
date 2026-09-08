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
      @response = FranceTravailClient.cancel_participation(
        france_travail_id: @france_travail_id,
        headers: ft_user_headers
      )

      handle_failure! unless @response.success? || participation_not_found?
    end

    def handle_failure!
      fail!(
        "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Suppression de Participation).\n" \
        "Status: #{@response.status}\n Body: #{@response.body.force_encoding('UTF-8')}"
      )
    end

    def participation_not_found?
      # FT returns ID_NON_RECONNU when the participation ID is not found, typically after duplicate users
      # were merged on FT side. The participation no longer exists there, so the cancellation goal is met.
      response_body = JSON.parse(@response.body.force_encoding("UTF-8"))
      response_body["codeErreur"] == "ID_NON_RECONNU"
    rescue JSON::ParserError
      false
    end

    def ft_user_headers
      call_service!(BuildUserAuthenticatedHeaders, user: @user).headers
    end
  end
end
