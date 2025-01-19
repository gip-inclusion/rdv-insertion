class UserListUpload::InviteUsersJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(user_list_upload_id, invitation_formats)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_collection = user_list_upload.user_collection
    return if user_collection.all_invitations_attempted?

    user_collection.user_rows_marked_for_invitation.each do |user_row|
      invitation_formats.each do |format|
        user_row.invite_user(format) if user_row.invitable_by?(format)
      end
    end
  end
end
