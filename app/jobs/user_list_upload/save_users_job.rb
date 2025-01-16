class UserListUpload::SaveUsersJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_list_upload.user_rows.each(&:save_user)
  end
end
