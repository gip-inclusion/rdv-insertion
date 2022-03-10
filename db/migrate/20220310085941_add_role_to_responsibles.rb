class AddRoleToResponsibles < ActiveRecord::Migration[6.1]
  def change
    add_column :responsibles, :role, :string
  end
end
