class RetrieveGeolocalisation < BaseService
  API_ADRESSE_URL = "https://api-adresse.data.gouv.fr/search/".freeze

  def initialize(address:, department_number:)
    @address = address
    @department_number = department_number
  end

  def call
    check_address_presence!
    request_geo_api!
    retrieve_geolocalisation!
  end

  private

  def check_address_presence!
    fail!("l'addresse doit être renseignée") if @address.blank?
  end

  def request_geo_api!
    return if geo_api_response.success?

    fail!("la requête pour récupérer les coordonnées a échoué")
  end

  def geo_api_response
    @geo_api_response ||= Faraday.get(API_ADRESSE_URL, { q: @address }, { "Content-Type" => "application/json" })
  end

  def response_body
    JSON.parse(geo_api_response.body)
  end

  # rubocop:disable Metrics/AbcSize
  def retrieve_geolocalisation!
    fail!("les coordonnées n'ont pas pu être retrouvées") if selected_feature.nil?

    result.longitude, result.latitude = coordinates
    result.city_code = city_code
    result.street_ban_id = street_ban_id
    result.name = name
    result.postcode = postcode
    result.city = city
  end
  # rubocop:enable Metrics/AbcSize

  def city_code
    selected_feature["properties"]["citycode"]
  end

  def coordinates
    selected_feature["geometry"]["coordinates"]
  end

  def name
    selected_feature["properties"]["name"]
  end

  def postcode
    selected_feature["properties"]["postcode"]
  end

  def city
    selected_feature["properties"]["city"]
  end

  def street_ban_id
    # like in RDVS: 5 chars for city insee code, 1 for _, 4 for street fantoir
    selected_feature["properties"]["id"].first(10)
  end

  def selected_feature
    # we take the first result that checks that it is in the right department
    response_body["features"].find do |f|
      f["properties"]["context"].downcase.include?(@department_number)
    end
  end
end
