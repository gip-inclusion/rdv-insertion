module AssetHelper
  class << self
    def asset_exists?(asset_path)
      if Rails.env.production?
        # Pre-compiled
        Rails.application.assets_manifest.assets.key?(asset_path)
      else
        # Dynamic compilation
        Rails.application.assets.find_asset(asset_path).present?
      end
    end

    def retrieve_asset_path(asset_path)
      if Rails.env.production?
        # Pre-compiled
        Rails.application.assets_manifest.assets[asset_path]
      else
        # Dynamic compilation
        Rails.application.assets.find_asset(asset_path)&.digest_path
      end
    end
  end
end
