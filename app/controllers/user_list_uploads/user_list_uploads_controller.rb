module UserListUploads
  class UserListUploadsController < BaseController
    before_action :set_all_configurations, :set_category_configuration, :set_file_configuration, only: :new
    before_action :set_user_list_upload, only: [:show]

    def show
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows
      @user_rows_with_errors = @user_collection.user_rows_with_errors
      @category_configuration = @user_list_upload.category_configuration
    end

    def new; end

    def enrich_with_cnaf_data
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload

      if @user_list_upload.update_rows(enrich_with_cnaf_data_params)
        flash[:success] = "Les données de #{@user_list_upload.user_rows_enriched_with_cnaf_data.count} usagers" \
                          " ont été mises à jour avec les données du fichier importé"
        turbo_stream_redirect(user_list_upload_path(@user_list_upload))
      else
        turbo_stream_display_error_modal(@user_list_upload.errors.full_messages)
      end
    end

    def create
      @user_list_upload = UserListUpload.new(
        agent: current_agent, structure: current_structure, **user_list_upload_params
      )
      authorize @user_list_upload

      if @user_list_upload.save
        redirect_to user_list_upload_path(@user_list_upload)
      else
        turbo_stream_display_error_modal(@user_list_upload.errors.full_messages)
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.preload(category_configuration: :motif_category).find(params[:id])
      authorize @user_list_upload
    end

    def set_all_configurations
      @all_configurations = policy_scope(current_structure.category_configurations).preload(:file_configuration)
    end

    def set_category_configuration
      @category_configuration =
        if params[:category_configuration_id] == "none"
          nil
        else
          @all_configurations.find(params[:category_configuration_id])
        end
    end

    def user_list_upload_params
      params.permit(
        :category_configuration_id, :file_name,
        user_rows_attributes: [
          :first_name, :last_name, :email, :phone_number, :role, :title, :nir, :department_internal_id,
          :france_travail_id, :rights_opening_date, :affiliation_number, :birth_date, :birth_name, :address,
          :organisation_search_terms, :referent_email, { tag_values: [] }
        ]
      )
    end

    def enrich_with_cnaf_data_params
      params.expect(rows_cnaf_data: [[:id, { cnaf_data: [:email, :phone_number, :rights_opening_date] }]])
    end

    def set_file_configuration
      @file_configuration =
        if @category_configuration.present?
          @category_configuration.file_configuration
        else
          # we take the file_configuration linked to the largest number of category_configurations in this case
          @all_configurations.map(&:file_configuration).tally.max_by { |_file_config, count| count }.first
        end
    end
  end
end
