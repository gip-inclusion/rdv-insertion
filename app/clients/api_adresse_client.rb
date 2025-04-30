class ApiAdresseClient
  URL = "https://data.geopf.fr/geocodage/search/".freeze

  def self.get_geocoding(address, **params)
    Faraday.get(URL, { q: address }.merge(params), { "Content-Type" => "application/json" })
  end
end
