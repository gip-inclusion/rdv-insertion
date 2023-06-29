class ChangeCarnetDeBordColumnTypes < ActiveRecord::Migration[7.0]
  def up
    change_column :departments, :carnet_de_bord_deploiement_id, :string
    change_column :applicants, :carnet_de_bord_carnet_id, :string
  end

  def down
    change_column :departments, :carnet_de_bord_deploiement_id, :bigint, using: "carnet_de_bord_deploiement_id::bigint"
    change_column :applicants, :carnet_de_bord_carnet_id, :bigint, using: "carnet_de_bord_carnet_id::bigint"
  end
end
