class AddCdbIdsToDepartmentsAndApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :departments, :carnet_de_bord_deploiement_id, :bigint
    add_column :applicants, :carnet_de_bord_carnet_id, :bigint
  end
end
