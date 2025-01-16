module UserListUploads
  class UserSaveAttemptsController < BaseController
    before_action :set_user_list_upload, only: [:create_many, :index, :create]
    before_action :set_user_row, only: [:create]

    def create_many
      @user_list_upload.user_collection.mark_selected_rows_for_user_save!(selected_ids)
      UserListUpload::SaveUsersJob.perform_later(@user_list_upload.id)
      redirect_to user_list_upload_user_save_attempts_path(user_list_upload_id: @user_list_upload)
    end

    def index
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_rows = @user_collection.user_rows_marked_for_user_save
      @user_rows_with_user_save_errors = @user_collection.user_rows_with_user_save_errors
      @user_rows_with_user_save_attempted = @user_collection.user_rows_with_user_save_attempted
    end

    def create
      if @user_row.save_user
        render json: { success: true }
      else
        render json: { success: false, errors: @user_row.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def set_user_row
      @user_row = @user_list_upload.user_rows.find_by!(id: params[:user_row_id])
    end

    def selected_ids
      params.permit(selected_ids: []).fetch(:selected_ids, [])
    end
  end
end
