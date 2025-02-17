module UserListUploads
  class InvitationAttemptsController < BaseController
    before_action :set_user_list_upload, only: [:index, :select_rows, :create_many]

    def select_rows
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows_with_user_save_success
    end

    def create_many
      @user_collection = @user_list_upload.user_collection
      @user_collection.mark_selected_rows_for_invitation!(selected_ids)
      UserListUpload::InviteUsersJob.perform_later(@user_list_upload.id, invitation_formats)
      redirect_to user_list_upload_invitation_attempts_path(user_list_upload_id: @user_list_upload.id)
    end

    def index
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows_marked_for_invitation
      @user_rows_with_invitation_errors = @user_collection.user_rows_with_invitation_errors
      @user_rows_with_invitation_attempted = @user_collection.user_rows_with_invitation_attempted
      @all_invitations_attempted = @user_rows_with_invitation_attempted.count == @user_rows.count
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def selected_ids
      params.permit(selected_ids: []).fetch(:selected_ids, [])
    end

    def invitation_formats
      [params[:email], params[:sms]].compact.map(&:downcase)
    end
  end
end
