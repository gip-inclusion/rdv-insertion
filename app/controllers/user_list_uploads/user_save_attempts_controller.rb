module UserListUploads
  class UserSaveAttemptsController < BaseController
    before_action :set_user_list_upload, only: [:create_many, :index, :create]

    def create_many
      @user_list_upload.user_collection.mark_selected_rows_for_user_save!(selected_uids)
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
      if @user_list_upload.save_row_user(params[:row_uid])
        render json: { success: true }
      else
        render json: { success: false, errors: @user_list_upload.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def selected_uids
      params.permit(selected_uids: []).fetch(:selected_uids, [])
    end
  end
end
