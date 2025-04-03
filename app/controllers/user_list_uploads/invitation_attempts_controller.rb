module UserListUploads
  class InvitationAttemptsController < BaseController
    before_action :set_user_list_upload, only: [:index, :select_rows, :create_many]

    def select_rows
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows_with_user_save_success
      @number_of_user_rows_selected = @user_list_upload.user_rows_selected_for_invitation.length
      @total_number_of_user_rows = @user_list_upload.user_rows.length
    end

    def create_many
      UserListUpload::InviteUsersJob.perform_later(@user_list_upload.id, invitation_formats)
      redirect_to user_list_upload_invitation_attempts_path(user_list_upload_id: @user_list_upload.id)
    end

    def index
      @user_collection = @user_list_upload.user_collection
      @user_collection.sort_by!(**sort_params) if sort_params_valid?
      @user_collection.search!(params[:search_query]) if params[:search_query].present?
      @user_rows = @user_collection.user_rows_selected_for_invitation
      @user_rows_with_invitation_errors = @user_collection.user_rows_with_invitation_errors
      @user_rows_with_invitation_attempted = @user_collection.user_rows_with_invitation_attempted
      @all_invitations_attempted = @user_rows_with_invitation_attempted.count == @user_rows.count
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def invitation_formats
      [params[:format_email], params[:format_sms]].compact.map(&:downcase)
    end
  end
end
