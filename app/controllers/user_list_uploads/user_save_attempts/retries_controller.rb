module UserListUploads
  module UserSaveAttempts
    class RetriesController < ApplicationController
      before_action :set_user_list_upload, :set_user_row, only: [:new, :create]

      def new
        @user_save_attempt = @user_row.last_user_save_attempt
      end

      def create
        if @user_row.save_user.success?
          turbo_stream_display_modal(
            partial: "user_list_uploads/user_save_attempts/retries/user_save_suceeded",
            locals: { user_row: @user_row }
          )
        else
          turbo_stream_display_custom_error_modal(
            errors: @user_row.last_user_save_attempt.service_errors,
            title: "La sauvegarde de l'usager a échoué"
          )
        end
      end

      private

      def set_user_list_upload
        @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
        authorize @user_list_upload, :edit?
      end

      def set_user_row
        @user_row = @user_list_upload.user_rows.find(params[:user_row_id])
      end
    end
  end
end
