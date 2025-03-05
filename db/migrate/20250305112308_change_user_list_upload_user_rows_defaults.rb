class ChangeUserListUploadUserRowsDefaults < ActiveRecord::Migration[8.0]
  def change
    change_column_default :user_list_upload_user_rows, :marked_for_invitation, true
    change_column_default :user_list_upload_user_rows, :marked_for_user_save, true
  end
end
