module UserListUploads
  class UserRowCellsController < ApplicationController
    before_action :ensure_user_row_attribute_is_editable, :set_user_list_upload, :set_user_row

    def edit
      render turbo_stream: turbo_stream.replace("user-row-cell-#{params[:user_row_id]}-#{params[:attribute]}",
                                                partial: "user_list_uploads/edit_row_attribute",
                                                locals: { user_row: @user_row, attribute: params[:attribute] })
    end

    private

    def ensure_user_row_attribute_is_editable
      return if UserListUpload::UserRow::EDITABLE_ATTRIBUTES.include?(params[:attribute].to_sym)

      turbo_stream_display_error_modal(["L'attribut #{params[:attribute]} n'est pas editable"])
    end

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def set_user_row
      @user_row = @user_list_upload.user_rows.find(params[:user_row_id])
    end
  end
end
