class AddMissingIndicesOnUsers < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :deleted_at
    add_index :users, [:role, :affiliation_number]
  end
end
