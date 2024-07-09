# https://github.com/geocoders/geocodejson-spec/blob/master/draft/README.md#feature-object
class GeoJson::Feature
  def initialize(params)
    @params = params.deep_symbolize_keys
  end

  def properties
    @params[:properties]
  end

  def city
    properties[:city]
  end

  def city_code
    properties[:citycode]
  end

  def post_code
    properties[:postcode]
  end

  def street_ban_id
    properties[:id].first(10)
  end

  def house_number
    properties[:housenumber]
  end

  def street
    properties[:street]
  end

  def context
    properties[:context]
  end

  def coordinates
    @params.dig(:geometry, :coordinates)
  end

  def department_number
    context.split(",").first
  end

  def longitude
    coordinates.first
  end

  def latitude
    coordinates.last
  end

  def normalized_city
    normalize(city)
  end

  def matches_city?(address:, department_number:)
    normalize(address).include?(normalized_city) && matches_department?(department_number)
  end

  def matches_post_code?(address:, department_number:)
    address.include?(post_code) && matches_department?(department_number)
  end

  def matches_department?(matching_department_number)
    department_number == matching_department_number
  end

  def to_h
    { city:, city_code:, post_code:, latitude:, longitude:, street_ban_id:, house_number:, street:, department_number: }
  end

  private

  def normalize(address)
    Address::Normalizer.new(address).normalize
  end
end
