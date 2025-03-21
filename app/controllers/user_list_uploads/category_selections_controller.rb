module UserListUploads
  class CategorySelectionsController < BaseController
    def new
      @category_configurations = policy_scope(current_structure.category_configurations_sorted)
                                 .preload(:motif_category)
                                 .uniq(&:motif_category_id)

      @selected_category_id = params[:category_configuration_id]
    end
  end
end
