class AddIndexesOnOrientations < ActiveRecord::Migration[7.1]
  def change
    add_index :orientations, [:starts_at, :ends_at]
  end
end
