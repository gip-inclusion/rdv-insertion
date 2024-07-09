# https://github.com/geocoders/geocodejson-spec/blob/master/draft/README.md#main-object
class GeoJson::FeatureCollection
  def initialize(features_params)
    @features_params = features_params
  end

  def find_matching_city_feature(address:, department_number:)
    features.find { |feature| feature.matches_city?(address:, department_number:) }
  end

  def find_matching_post_code_feature(address:, department_number:)
    features.find { |feature| feature.matches_post_code?(address:, department_number:) }
  end

  def find_matching_department_feature(department_number)
    features.find { |feature| feature.matches_department?(department_number) }
  end

  def features
    @features ||= @features_params.map { |feature_params| GeoJson::Feature.new(feature_params) }
  end
end
