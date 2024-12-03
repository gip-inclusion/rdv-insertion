class CreateUnavailableCreneauLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :unavailable_creneau_logs do |t|
      t.references :organisation, null: false, foreign_key: true
      t.integer :number_of_invitations_affected

      t.timestamps
    end
  end
end
