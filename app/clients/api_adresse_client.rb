class ApiAdresseClient
  URL = "https://api-adresse.data.gouv.fr/search/".freeze

  def self.get_geocoding(address, **params)
    # the endpoint accepts only queries starting with an alphanumeric character
    address = address.gsub(/\A[^\p{Alnum}]+/, "")
    Faraday.get(URL, { q: address }.merge(params), { "Content-Type" => "application/json" })
  end
end
