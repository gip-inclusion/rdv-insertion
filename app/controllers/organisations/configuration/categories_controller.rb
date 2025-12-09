module Organisations
  module Configuration
    class CategoriesController < BaseController
      def show
        @category_configurations = @organisation.category_configurations
                                                .includes(:motif_category, :file_configuration)
                                                .order("motif_categories.name")
        @motifs_count_by_category = @organisation.motifs
                                                 .active
                                                 .group(:motif_category_id)
                                                 .count
      end
    end
  end
end
