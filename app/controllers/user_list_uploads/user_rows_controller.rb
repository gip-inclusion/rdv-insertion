module UserListUploads
  class UserRowsController < BaseController
    before_action :set_user_list_upload

    # rubocop:disable Metrics/AbcSize
    def update
      if @user_list_upload.update_row(params[:uid], row_params.to_h.symbolize_keys)
        respond_to do |format|
          format.turbo_stream { redirect_to user_list_upload_path(id: @user_list_upload.id) }
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.turbo_stream { turbo_stream_display_error_modal(@user_list_upload.errors.full_messages) }
          format.json do
            render json: { success: false, errors: @user_list_upload.errors.full_messages },
                   status: :unprocessable_entity
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
    end

    def row_params
      params.require(:user_row).permit(
        :title, :first_name, :last_name, :affiliation_number, :phone_number, :email, :assigned_organisation_id
      )
    end
  end
end
