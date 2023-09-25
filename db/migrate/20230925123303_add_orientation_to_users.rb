class AddOrientationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :orientation, :integer
  end
end
