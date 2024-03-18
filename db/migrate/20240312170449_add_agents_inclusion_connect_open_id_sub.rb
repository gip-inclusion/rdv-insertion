class AddAgentsInclusionConnectOpenIdSub < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :inclusion_connect_open_id_sub, :string
    add_index :agents, :inclusion_connect_open_id_sub, unique: true, where: "inclusion_connect_open_id_sub IS NOT NULL"
  end
end
