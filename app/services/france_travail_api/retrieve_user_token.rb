module FranceTravailApi
  class RetrieveUserToken < BaseService
    # https://francetravail.io/produits-partages/catalogue/rechercher-usager/documentation#/api-reference/

    def initialize(user:, access_token:)
      @user = user
      @access_token = access_token
    end

    def call
      send_request!
      result.user_token = @france_travail_user_token
    end

    private

    def send_request!
      france_travail_client = FranceTravailClient.new
      response = france_travail_client.retrieve_user_token(payload: user_payload)

      if response.success?
        response_body = JSON.parse(response.body)
        @france_travail_user_token = response_body["jetonUsager"]
      else
        fail!(
          "Erreur lors de l'appel à l'api recherche-usager FT.\n" \
          "Status: #{response.status}\n Body: #{response.body}"
        )
      end
    end

    def user_payload
      {
        dateNaissance: @user.birth_date.to_s,
        nir: @user.nir
      }
    end
  end
end
