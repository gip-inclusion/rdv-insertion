module FranceTravailApi
  class BuildUserAuthenticatedHeaders < BaseService
    def initialize(user:)
      @user = user
    end

    def call
      access_token = call_service!(RetrieveAccessToken).access_token
      user_token = call_service!(RetrieveUserToken, user: @user, access_token: access_token).user_token

      # Doc FT : Dans le cadre d'un appel depuis un traitement de type batch,
      #   renseigner "BATCH" pour pa-identifiant-agent.
      # Dans le cadre d'un appel depuis un traitement de type batch,
      #   renseigner un nom logique de batch pour pa-nom-agent et pa-prenom-agent.
      result.headers = {
        "ft-jeton-usager" => user_token,
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "pa-identifiant-agent" => "BATCH",
        "pa-nom-agent" => "Webhooks Participation RDV-Insertion",
        "pa-prenom-agent" => "Webhooks Participation RDV-Insertion"
      }
    end
  end
end
