class UserListUpload::CaptureProcessingTimestampJob < ApplicationJob
  def perform(user_list_upload_id, timestamp_name, value)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    processing_log = user_list_upload.processing_log || user_list_upload.build_processing_log
    processing_log.update!(timestamp_name => value)
  end
end
