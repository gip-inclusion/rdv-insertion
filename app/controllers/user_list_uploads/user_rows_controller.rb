module UserListUploads
  class UserRowsController < BaseController
    before_action :set_user_list_upload, :set_user_row

    def show
      render turbo_stream: turbo_stream.replace("user-row-#{params[:uid]}",
                                                partial: "user_list_uploads/user_list_uploads/user_row",
                                                locals: { user_row: @user_row })
    end

    def update
      if @user_row.update(row_params.to_h.symbolize_keys)
        respond_to do |format|
          format.turbo_stream do
            redirect_to user_list_upload_path(@user_list_upload, user_with_errors: params[:user_with_errors])
          end
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :update_error }
          format.json do
            render json: { success: false, errors: @user_row.errors.full_messages },
                   status: :unprocessable_entity
          end
        end
      end
    end

    def show_details
      respond_to :turbo_stream
    end

    def hide_details
      respond_to :turbo_stream
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def set_user_row
      @user_row = @user_list_upload.user_rows.find_by!(uid: params[:uid] || params[:user_row_uid])
    end

    def row_params
      params.require(:user_row).permit(
        :title, :first_name, :last_name, :affiliation_number, :phone_number, :email, :assigned_organisation_id
      )
    end
  end
end
