class UserListUpload::InviteUserJob < ApplicationJob
  def perform(user_row_id, format)
    user_row = UserListUpload::UserRow.find(user_row_id)
    user_row.invite_user(format)
  end
end
