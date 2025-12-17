module Organisations
  module Configuration
    class CategoriesController < BaseController
      def show
        # Data loading delegated to CategoryConfigurationsController#index via turbo_frame
      end
    end
  end
end
