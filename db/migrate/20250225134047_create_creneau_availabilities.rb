class CreateCreneauAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :creneau_availabilities do |t|
      t.integer :number_of_creneaux_available
      t.references :category_configuration, null: false, foreign_key: true

      t.timestamps
    end
  end
end
