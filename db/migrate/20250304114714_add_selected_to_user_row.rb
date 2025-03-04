class AddSelectedToUserRow < ActiveRecord::Migration[8.0]
  def change
    add_column :user_list_upload_user_rows, :selected, :boolean, default: true
  end
end
