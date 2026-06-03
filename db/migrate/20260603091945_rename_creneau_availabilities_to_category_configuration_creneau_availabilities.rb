class RenameCreneauAvailabilitiesToCategoryConfigurationCreneauAvailabilities < ActiveRecord::Migration[8.1]
  def change
    rename_table :creneau_availabilities, :category_configuration_creneau_availabilities
  end
end
