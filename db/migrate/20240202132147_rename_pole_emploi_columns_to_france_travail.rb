class RenamePoleEmploiColumnsToFranceTravail < ActiveRecord::Migration[7.0]
  def change
    rename_column :file_configurations, :pole_emploi_id_column, :france_travail_id_column
    rename_column :messages_configurations, :display_pole_emploi_logo, :display_france_travail_logo
    rename_column :users, :pole_emploi_id, :france_travail_id
  end
end
