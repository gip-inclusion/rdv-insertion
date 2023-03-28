class AddNirAndPoleEmploiIdToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :nir, :string
    add_column :applicants, :pole_emploi_id, :string
  end
end
