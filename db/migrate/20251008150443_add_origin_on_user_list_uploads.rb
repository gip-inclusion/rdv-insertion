class AddOriginOnUserListUploads < ActiveRecord::Migration[8.0]
  def change
    add_column :user_list_uploads, :origin, :string
    add_index :user_list_uploads, :origin
    up_only do
      UserListUpload.update_all(origin: "file_upload")
    end
    change_column_null :user_list_uploads, :origin, false
  end
end
