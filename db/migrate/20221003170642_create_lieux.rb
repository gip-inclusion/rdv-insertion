class CreateLieux < ActiveRecord::Migration[7.0]
  def change
    create_table :lieux do |t|
      t.bigint :rdv_solidarites_lieu_id
      t.string :name
      t.string :address
      t.string :phone_number
      t.datetime :last_webhook_update_received_at
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
