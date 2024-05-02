class RemoveIndependantFromCdFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    remove_column :organisations, :independant_from_cd, :boolean
  end
end
