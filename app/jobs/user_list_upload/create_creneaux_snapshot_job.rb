class UserListUpload::CreateCreneauxSnapshotJob < ApplicationJob
  queue_as :within_30s

  def perform(user_list_upload_id)
    user_list_upload = UserListUpload.find_by(id: user_list_upload_id)
    return if user_list_upload.nil?

    call_service!(
      UserListUpload::CreateCreneauxSnapshot,
      user_list_upload:
    )

    user_list_upload.broadcast_refresh
  end
end
