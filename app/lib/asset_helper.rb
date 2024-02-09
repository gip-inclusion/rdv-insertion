module AssetHelper
  class << self
    def find_asset(asset_path)
      if Rails.env.production?
        # Pre-compiled
        Rails.application.assets_manifest.assets.key?(asset_path)
      else
        # Dynamic compilation
        Rails.application.assets.find_asset(asset_path).present?
      end
    end
  end
end
