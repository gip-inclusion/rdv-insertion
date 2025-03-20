class UserListUpload::SaveUsersJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_collection = user_list_upload.user_collection

    return if user_collection.all_saves_attempted?

    user_collection.user_rows_selected_for_user_save.each do |user_row|
      next if user_row.user_save_succeded?

      user_row.save_user
    end
  end
end
