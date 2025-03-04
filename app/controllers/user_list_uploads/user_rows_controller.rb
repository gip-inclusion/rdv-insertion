module UserListUploads
  class UserRowsController < BaseController
    before_action :set_user_list_upload
    before_action :set_user_row, except: :update_all
    before_action :set_user_row_partial, only: [:show, :update]

    def show
      render turbo_stream: turbo_stream.replace("user-row-#{params[:id]}",
                                                partial: @user_row_partial,
                                                locals: { user_row: @user_row })
    end

    def update
      success = @user_row.update(row_params.to_h.symbolize_keys)

      respond_to do |format|
        format.turbo_stream do
          if success
            redirect_to request.referer
          else
            render :update_error
          end
        end

        format.json { render json: { success: } }
      end
    end

    def update_all
      success = @user_list_upload.user_rows.update_all(
        selected: params[:selected]
      )

      render json: { success: }
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
      @user_row = @user_list_upload.user_rows.find(params[:id] || params[:user_row_id])
    end

    def set_user_row_partial
      @user_row_partial = if @user_row.marked_for_user_save?
                            "user_list_uploads/user_save_attempts/user_row"
                          else
                            "user_list_uploads/user_list_uploads/user_row"
                          end
    end

    def row_params
      params.expect(
        user_row: [:selected, :title, :first_name, :last_name, :affiliation_number, :phone_number, :email,
                   :assigned_organisation_id]
      )
    end
  end
end
