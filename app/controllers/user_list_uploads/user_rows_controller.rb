module UserListUploads
  class UserRowsController < ApplicationController
    before_action :set_user_list_upload

    def update
      if @user_list_upload.update_row(params[:uid], row_params.to_h.symbolize_keys)
        redirect_to structure_user_list_upload_path(id: @user_list_upload.id)
      else
        turbo_stream_display_error_modal(@user_list_upload.errors.full_messages)
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
    end

    def row_params
      params.require(:user_row).permit(:title, :first_name, :last_name, :affiliation_number, :phone_number, :email)
    end
  end
end
