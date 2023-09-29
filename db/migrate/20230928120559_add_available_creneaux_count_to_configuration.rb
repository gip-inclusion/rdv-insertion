class AddAvailableCreneauxCountToConfiguration < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :available_creneaux_count, :integer
  end
end
