class UserListUpload::SaveUserJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_row_id, broadcast_refresh: true)
    user_row = UserListUpload::UserRow.find(user_row_id)
    user_row.save_user
    user_row.user_list_upload.broadcast_refresh_later if broadcast_refresh
  end
end
