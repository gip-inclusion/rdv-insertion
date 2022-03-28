class AddDirectionNamesToDepartment < ActiveRecord::Migration[6.1]
  def up
    add_column :departments, :direction_names, :string, array: true
  end

  def down
    remove_column :departments, :direction_names, :string, array: true
  end
end
