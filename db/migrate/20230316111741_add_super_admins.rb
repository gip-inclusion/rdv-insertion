class AddSuperAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :super_admin, :boolean, default: false
  end
end
