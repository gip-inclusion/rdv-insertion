class FranceTravailClient
  def initialize(user: nil)
    @user = user
  end

  def create_participation(payload:)
    Faraday.post(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous",
      payload.to_json,
      request_headers
    )
  end

  def update_participation(payload:)
    Faraday.put(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous",
      payload.to_json,
      request_headers
    )
  end

  def delete_participation(france_travail_id:)
    Faraday.delete(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous/#{france_travail_id}",
      request_headers
    )
  end

  def user_token(payload:)
    Faraday.post(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rechercher-usager/v1/usagers/recherche",
      payload.to_json,
      request_headers
    )
  end

  def request_headers
    @user.present? ? user_request_headers : client_request_headers
  end

  def user_request_headers
    FranceTravailApi::BuildUserAuthenticatedHeaders.call(user: @user).headers
  end

  def client_request_headers
    access_token = FranceTravailApi::RetrieveAccessToken.call.access_token

    {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end
end
