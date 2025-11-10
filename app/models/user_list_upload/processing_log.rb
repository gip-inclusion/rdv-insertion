class UserListUpload::ProcessingLog < ApplicationRecord
  self.table_name = "user_list_upload_processing_logs"

  belongs_to :user_list_upload
end
