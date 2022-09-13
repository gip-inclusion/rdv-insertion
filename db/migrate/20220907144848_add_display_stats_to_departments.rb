class AddDisplayStatsToDepartments < ActiveRecord::Migration[7.0]
  def change
    add_column :departments, :display_in_stats, :boolean, default: true
  end
end
