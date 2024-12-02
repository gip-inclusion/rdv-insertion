module UserListUploads
  class UserSavesController < ApplicationController
    before_action :set_user_list_upload, only: [:trigger, :index]

    def index
    end

    def trigger
      TriggerUserListUploadSavesJob.perform_later(@user_list_upload)
      redirect_to structure_user_list_upload_user_saves_path(user_list_upload_id: @user_list_upload)
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
    end
  end
end
