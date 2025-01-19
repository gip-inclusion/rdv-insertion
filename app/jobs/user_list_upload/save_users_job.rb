class UserListUpload::SaveUsersJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    return if user_list_upload.user_collection.all_saves_attempted?

    user_list_upload.user_rows.each do |user_row|
      next if user_row.user_save_succeded?

      user_row.save_user
    end
  end
end
