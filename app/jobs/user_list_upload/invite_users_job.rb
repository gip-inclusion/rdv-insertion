class UserListUpload::InviteUsersJob < ApplicationJob
  def perform(user_list_upload_id, invitation_formats)
    user_list_upload = UserListUpload.find(user_list_upload_id)
    user_collection = user_list_upload.user_collection
    user_collection.user_rows_marked_for_invitation.each do |user_row|
      invitation_formats.each do |format|
        user_collection.invite_row_user(user_row.uid, format)
      end
    end
  end
end
