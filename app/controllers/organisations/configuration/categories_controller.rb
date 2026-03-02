module Organisations
  module Configuration
    class CategoriesController < BaseController
      def show
        @category_configurations = @organisation.category_configurations
                                                .includes(:motif_category, :file_configuration)
                                                .order(:position)
        @motifs_by_category = @organisation.motifs.group_by(&:motif_category_id)
        @newly_created_category_configuration =
          if params[:newly_created_category_configuration_id]
            @category_configurations.find { |cc| cc.id == params[:newly_created_category_configuration_id].to_i }
          end
      end
    end
  end
end
