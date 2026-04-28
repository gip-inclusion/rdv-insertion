class RemoveUidFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :uid, :string
  end
end
