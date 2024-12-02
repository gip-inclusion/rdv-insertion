class UserListUpload::SaveUsersJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_list_upload.user_rows.each do |user_row|
      user_list_upload.save_row_user(user_row.uid)
    end
  end
end
