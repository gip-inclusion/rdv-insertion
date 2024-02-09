module AssetHelper
  class << self
    def find_asset(asset_path)
      if Rails.configuration.assets.respond_to?(:find_asset)
        # Dynamic compilation
        Rails.application.assets.find_asset(asset_path).present?
      else
        # Pre-compiled
        Rails.application.assets_manifest.assets.key?(asset_path)
      end
    end
  end
end
