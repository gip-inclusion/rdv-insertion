class AddIndexToTriggers < ActiveRecord::Migration[7.1]
  def change
    add_index :invitations, :trigger
  end
end
