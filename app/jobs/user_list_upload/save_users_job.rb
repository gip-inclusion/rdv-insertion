class UserListUpload::SaveUsersJob < ApplicationJob
  sidekiq_options retry: 0

  before_perform :capture_user_saves_started_at
  after_perform :capture_user_saves_ended_at

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_collection = user_list_upload.user_collection

    return if user_collection.all_saves_attempted?

    user_collection.user_rows_selected_for_user_save.each do |user_row|
      next if user_row.user_save_succeeded?

      user_row.save_user
    end
  end

  private

  def capture_user_saves_started_at
    UserListUpload::CaptureProcessingTimestampJob.perform_later(
      arguments.first, "user_saves_started_at", Time.zone.now.to_s
    )
  end

  def capture_user_saves_ended_at
    UserListUpload::CaptureProcessingTimestampJob.perform_later(
      arguments.first, "user_saves_ended_at", Time.zone.now.to_s
    )
  end
end
