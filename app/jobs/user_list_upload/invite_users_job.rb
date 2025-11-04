class UserListUpload::InviteUsersJob < ApplicationJob
  sidekiq_options retry: 0

  before_perform :capture_invitations_started_at
  after_perform :capture_invitations_ended_at

  def perform(user_list_upload_id, invitation_formats)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_collection = user_list_upload.user_collection
    return if user_collection.all_invitations_attempted?

    user_collection.user_rows_selected_for_invitation.each do |user_row|
      invitation_formats.each do |format|
        user_row.invite_user_by(format) if user_row.can_be_invited_through?(format)
      end
    end
  end

  private

  def capture_invitations_started_at
    UserListUpload::CaptureProcessingTimestampJob.perform_later(
      arguments.first, "invitations_started_at", Time.zone.now.to_s
    )
  end

  def capture_invitations_ended_at
    UserListUpload::CaptureProcessingTimestampJob.perform_later(
      arguments.first, "invitations_ended_at", Time.zone.now.to_s
    )
  end
end
