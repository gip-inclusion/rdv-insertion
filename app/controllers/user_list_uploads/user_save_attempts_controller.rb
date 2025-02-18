module UserListUploads
  class UserSaveAttemptsController < BaseController
    before_action :set_user_list_upload, only: [:create_many, :index]

    def create_many
      @user_list_upload.user_collection.mark_selected_rows_for_user_save!(selected_ids)
      UserListUpload::SaveUsersJob.perform_later(@user_list_upload.id)
      redirect_to user_list_upload_user_save_attempts_path(user_list_upload_id: @user_list_upload)
    end

    def index
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows_marked_for_user_save
      @user_rows_with_user_save_errors = @user_collection.user_rows_with_user_save_errors
      @user_rows_with_user_save_attempted = @user_collection.user_rows_with_user_save_attempted
      @all_saves_attempted = @user_rows_with_user_save_attempted.count == @user_rows.count
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def selected_ids
      params.permit(selected_ids: []).fetch(:selected_ids, [])
    end
  end
end
