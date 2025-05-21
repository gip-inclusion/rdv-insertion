module FranceTravailApi
  class RetrieveUserToken < BaseService
    class NoMatchingUser < StandardError; end
    # https://francetravail.io/produits-partages/catalogue/rechercher-usager-v2/documentation#/api-reference/

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
      response = FranceTravailClient.retrieve_user_token(payload: user_payload, headers: headers)
      @response_body = JSON.parse(response.body.force_encoding("UTF-8"))

      if response.success? && !no_matching_user?(response)
        @france_travail_user_token = @response_body["jetonUsager"]
      elsif no_matching_user?(response)
        raise NoMatchingUser, "Aucun usager trouvé avec l'id #{@user.id}"
      else
        fail!(
          "Erreur lors de l'appel à l'api recherche-usager FT.\n" \
          "Status: #{response.status}\n Body: #{response.body.force_encoding('UTF-8')}"
        )
      end
    end

    def user_payload
      {
        dateNaissance: @user.birth_date.to_s,
        nir: @user.nir
      }
    end

    def headers
      # Doc FT : Dans le cadre d'un appel depuis un traitement de type batch,
      #   renseigner "BATCH" pour pa-identifiant-agent.
      # Dans le cadre d'un appel depuis un traitement de type batch,
      #   renseigner un nom logique de batch pour pa-nom-agent et pa-prenom-agent.
      {
        "Authorization" => "Bearer #{@access_token}",
        "Content-Type" => "application/json",
        "pa-identifiant-agent" => "BATCH",
        "pa-nom-agent" => "Webhooks Participation RDV-Insertion",
        "pa-prenom-agent" => "Webhooks Participation RDV-Insertion"
      }
    end

    def no_matching_user?(response)
      # Actuellement le code retour S002 est "Aucun approchant n'a été trouvé" mais c'est une 200
      # Aussi le code retour S003 est "Plusieurs approchants ont été trouvés" mais c'est une 200
      # FT devrait corriger ça, auquel cas il faudra enlever cette condition.
      @response_body["codeRetour"].in?(%w[S002 S003]) || response.status == 404
    end
  end
end
