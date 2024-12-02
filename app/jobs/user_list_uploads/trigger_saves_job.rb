module UserListUploads
  class TriggerSavesJob < ApplicationJob
    def perform(user_list_upload_id, selected_row_uids = nil)
      user_list_upload = UserListUpload.find(user_list_upload_id)
      user_list_upload.user_rows.each do |user_row|
        next if selected_row_uids.present? && !user_row.uid.in?(selected_row_uids)

        UserListUpload::SaveUserJob.perform_later(user_list_upload_id, user_row.uid)
      end
    end
  end
end
