class CreateCreneauOpeningRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :creneau_opening_requests do |t|
      t.references :user_list_upload, null: false, foreign_key: true, type: :uuid
      t.references :recipient_agent, null: false, foreign_key: { to_table: :agents }
      t.integer :users_to_invite_count, null: false
      t.integer :available_creneaux_count, null: false
      t.string :uuid, null: false
      t.text :link, null: false
      t.datetime :email_sent_at
      t.datetime :clicked_at

      t.timestamps
    end

    add_index :creneau_opening_requests, :uuid, unique: true
  end
end
