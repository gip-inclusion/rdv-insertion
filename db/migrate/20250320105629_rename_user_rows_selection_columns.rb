class RenameUserRowsSelectionColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :user_list_upload_user_rows, :marked_for_invitation, :selected_for_invitation
    rename_column :user_list_upload_user_rows, :marked_for_user_save, :selected_for_user_save
  end
end
