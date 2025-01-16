module UserListUploads
  class UserRowCellsController < ApplicationController
    before_action :set_user_list_upload, :set_user_row

    def edit
      render turbo_stream: turbo_stream.replace("user-row-cell-#{params[:user_row_id]}-#{params[:attribute]}",
                                                partial: "user_list_uploads/user_list_uploads/edit_row_attribute",
                                                locals: { user_row: @user_row, attribute: params[:attribute] })
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
    end

    def set_user_row
      @user_row = @user_list_upload.user_rows.find(params[:user_row_id])
    end
  end
end

