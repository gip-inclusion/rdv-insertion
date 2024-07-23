class RetrieveAddressGeocodingParams < BaseService
  def initialize(address:, department_number:)
    @address = address
    @department_number = department_number
    @feature_collections = []
  end

  def call
    return if @address.blank?

    result.geocoding_params =
      geocoding_params_matching_city || geocoding_params_matching_post_code || geocoding_params_matching_department
  end

  private

  def geocoding_params_matching_city
    [@address, parsed_post_code_and_city, parsed_city].find do |query|
      next if query.blank?

      response = ApiAdresseClient.get_geocoding(query)
      fail!("Impossible d'appeler l'API addresse!\n response body: #{response.body}") unless response.success?

      feature_collection = ::GeoJson::FeatureCollection.new(JSON.parse(response.body)["features"])
      @feature_collections << feature_collection

      matching_feature = feature_collection.find_matching_city_feature(
        address: @address, department_number: @department_number
      )
      break matching_feature.to_h if matching_feature.present?
    end
  end

  def geocoding_params_matching_post_code
    retrieve_matching_geo_params_from_collections do |feature_collection|
      feature_collection.find_matching_post_code_feature(address: @address, department_number: @department_number)
    end
  end

  def geocoding_params_matching_department
    retrieve_matching_geo_params_from_collections do |feature_collection|
      feature_collection.find_matching_department_feature(@department_number)
    end
  end

  def retrieve_matching_geo_params_from_collections(&)
    @feature_collections.find do |feature_collection|
      matching_feature = yield(feature_collection)

      break matching_feature.to_h if matching_feature.present?
    end
  end

  def parsed_post_code_and_city = address_parser.parsed_post_code_and_city

  def parsed_city = address_parser.parsed_city

  def address_parser
    Address::Parser.new(@address)
  end
end
