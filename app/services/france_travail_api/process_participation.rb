module FranceTravailApi
  class ProcessParticipation < BaseService
    # https://francetravail.io/data/api/rechercher-usager/rdv-partenaire/documentation#/api-reference/
    include Webhooks::ReceiptHandler

    def initialize(participation_id:, timestamp:, event:)
      @participation = Participation.find(participation_id)
      @timestamp = timestamp
      @event = event
    end

    def call
      with_webhook_receipt(
        resource_model: "Participation",
        resource_id: @participation.id,
        timestamp: @timestamp
      ) do
        send_request!
      end
    end

    private

    def send_request!
      response = case @event
                 when :create
                   handle_create_request
                 when :update
                   france_travail_client.update_participation(payload: payload)
                 when :delete
                   # Qui des delete pour raison RGPD dans 2 ans ?
                   france_travail_client.delete_participation(france_travail_id: @participation.france_travail_id)
                 end

      handle_failure!(response) unless response.success?
    end

    def handle_create_request
      response = france_travail_client.create_participation(payload: payload)
      if response.success? && JSON.parse(response.body)["id"].present?
        # Update column to not trigger the webhook again
        @participation.update_column(:france_travail_id, JSON.parse(response.body)["id"])
      end
      response
    end

    def handle_failure!(response)
      fail!(
        "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Endpoint : #{@event}).\n" \
        "Status: #{response.status}\n Body: #{response.body}"
      )
    end

    def payload
      @participation.to_ft_payload
    end

    def france_travail_client
      FranceTravailClient.new(user: @participation.user)
    end
  end
end
