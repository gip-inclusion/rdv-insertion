module FranceTravailApi
  class RetrieveUserToken < BaseService
    # These errors are not retryable when called from the job
    class NoMatchingUser < StandardError; end
    class AccessForbidden < StandardError; end

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
      @response = retrieve_user_token
      @response_body = JSON.parse(@response.body.force_encoding("UTF-8"))

      @response.success? ? handle_success : handle_error
    end

    def handle_success
      if no_matching_user?
        raise NoMatchingUser, "Aucun usager trouvé avec l'id #{@user.id}"
      else
        @france_travail_user_token = @response_body["jetonUsager"]
      end
    end

    def no_matching_user?
      # Actuellement le code retour S002 est "Aucun approchant n'a été trouvé" mais c'est une 200
      # Aussi le code retour S003 est "Plusieurs approchants ont été trouvés" mais c'est une 200
      # FT devrait corriger ça, auquel cas il faudra enlever cette condition.
      @response_body["codeRetour"].in?(%w[S002 S003]) || @response.status == 404
    end

    def handle_error
      error_message = "Erreur lors de l'appel à l'api recherche-usager FT.\n" \
        "Status: #{@response.status}\n Body: #{@response.body.force_encoding('UTF-8')}"

      Rails.logger.error(error_message)

      raise AccessForbidden, error_message if access_forbidden?

      fail!(error_message)
    end

    def access_forbidden?
      # Les erreurs "Accès non autorisé" avec codeRetour "R001" sont rares et se produisent lorsque nous n'avons
      # pas accès à l'utilisateur. Il n'y a donc pas d'intérêt à les retenter.
      # Voir https://github.com/gip-inclusion/rdv-insertion/issues/2963
      @response.status == 403 && @response_body["codeRetour"] == "R001"
    end

    def retrieve_user_token
      if @user.nir_and_birth_date?
        FranceTravailClient.retrieve_user_token_by_nir(payload: user_payload_by_nir, headers: headers)
      elsif @user.valid_france_travail_id?
        FranceTravailClient.retrieve_user_token_by_france_travail_id(
          payload: user_payload_by_france_travail_id, headers: headers
        )
      else
        raise "User #{@user.id} is not retrievable in France Travail"
      end
    end

    def user_payload_by_nir
      {
        dateNaissance: @user.birth_date.to_s,
        nir: @user.nir
      }
    end

    def user_payload_by_france_travail_id
      {
        numeroFranceTravail: @user.france_travail_id
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
  end
end
