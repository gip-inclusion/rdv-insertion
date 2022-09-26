class CreateMotifs < ActiveRecord::Migration[7.0]
  def change
    create_table :motifs do |t|
      t.bigint :rdv_solidarites_motif_id
      t.string :name
      t.boolean :reservable_online
      t.datetime :deleted_at
      t.bigint :rdv_solidarites_service_id
      t.boolean :collectif
      t.integer :location_type
      t.integer :category
      t.datetime :last_webhook_update_received_at
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end

    add_index "motifs", ["rdv_solidarites_motif_id"], unique: true
  end
end
