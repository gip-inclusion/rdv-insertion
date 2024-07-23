class ApiAdresseClient
  URL = "https://api-adresse.data.gouv.fr/search/".freeze

  def self.get_geocoding(address, **params)
    Faraday.get(URL, { q: address }.merge(params), { "Content-Type" => "application/json" })
  end
end
