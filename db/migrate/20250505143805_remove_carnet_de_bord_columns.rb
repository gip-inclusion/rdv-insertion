class RemoveCarnetDeBordColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :departments, :carnet_de_bord_deploiement_id
    remove_column :users, :carnet_de_bord_carnet_id
  end
end
