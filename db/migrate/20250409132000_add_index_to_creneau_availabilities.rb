class AddIndexToCreneauAvailabilities < ActiveRecord::Migration[8.0]
  def change
    add_index :creneau_availabilities, :created_at
  end
end
