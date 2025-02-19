module UserListUploads
  module InvitationAttempts
    class RetriesController < ApplicationController
      before_action :set_user_list_upload, :set_user_row, only: [:new, :create]

      def new
        @invitation_errors = @user_row.invitation_errors.uniq
      end

      def create
        @user_row.invite_user
        if @user_row.all_invitations_failed?
          turbo_stream_display_custom_error_modal(
            errors: @user_row.last_invitation_attempt.service_errors,
            title: "L'invitation de l'usager a échoué"
          )
        else
          turbo_stream_display_modal(
            partial: "user_list_uploads/invitation_attempts/retries/invitation_succeeded",
            locals: { user_row: @user_row }
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
