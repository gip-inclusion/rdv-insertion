class AddUniqueConstraintToTagUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :tag_users, [:tag_id, :user_id], unique: true, name: "index_tag_users_on_tag_id_and_user_id"
  end
end
