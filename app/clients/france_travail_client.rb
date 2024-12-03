class FranceTravailClient
  def self.create_participation(payload:, headers:)
    Faraday.post(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous",
      payload.to_json,
      headers
    )
  end

  def self.update_participation(payload:, headers:)
    Faraday.put(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous",
      payload.to_json,
      headers
    )
  end

  def self.delete_participation(france_travail_id:, headers:)
    Faraday.delete(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous/#{france_travail_id}",
      {},
      headers
    )
  end

  def self.retrieve_user_token(payload:, headers:)
    Faraday.post(
      "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rechercher-usager/v1/usagers/recherche",
      payload.to_json,
      headers
    )
  end
end
