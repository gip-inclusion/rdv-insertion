module Organisations
  module Configuration
    class CategoriesController < BaseController
      def show
        @category_configurations = @organisation.category_configurations
                                                .includes(:motif_category, :file_configuration)
                                                .order("motif_categories.name")
        @motifs_by_category = @organisation.motifs
                                           .active
                                           .group_by(&:motif_category_id)
      end
    end
  end
end
