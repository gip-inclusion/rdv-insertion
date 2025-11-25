module FranceTravailApi
  class UpdateParticipation < BaseService
    # https://francetravail.io/data/api/rechercher-usager/rdv-partenaire/documentation#/api-reference/
    include Webhooks::ReceiptHandler

    # This error is raised when FT returns ID_NON_RECONNU, when the participation ID is not found
    # It happens when duplicate users were merged on FT side
    class ParticipationNotFound < StandardError; end

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
        send_update_request!
      end
    end

    private

    def send_update_request!
      @response = FranceTravailClient.update_participation(
        payload: @participation.to_ft_payload,
        headers: ft_user_headers
      )

      @response.success? ? @response : handle_failure!
    end

    def handle_failure!
      raise ParticipationNotFound, "L'ID France Travail de la participation n'existe plus" if participation_not_found?

      fail!(error_message)
    end

    def error_message
      "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Update de Participation).\n" \
        "Status: #{@response.status}\n Body: #{@response.body.force_encoding('UTF-8')}"
    end

    def participation_not_found?
      response_body = JSON.parse(@response.body.force_encoding("UTF-8"))
      response_body["codeErreur"] == "ID_NON_RECONNU"
    rescue JSON::ParserError
      false
    end

    def ft_user_headers
      call_service!(BuildUserAuthenticatedHeaders, user: @participation.user).headers
    end
  end
end
