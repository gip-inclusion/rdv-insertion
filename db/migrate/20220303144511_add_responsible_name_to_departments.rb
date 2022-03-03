class AddResponsibleNameToDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :responsible_name, :string
  end
end
