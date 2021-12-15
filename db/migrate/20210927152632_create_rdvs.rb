class CreateRdvs < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/AbcSize
  def change
    create_table :rdvs do |t|
      t.bigint :rdv_solidarites_rdv_id
      t.datetime :starts_at
      t.integer :duration_in_min
      t.references :department, null: false, foreign_key: true
      t.datetime :cancelled_at
      t.bigint :rdv_solidarites_motif_id
      t.bigint :rdv_solidarites_lieu_id
      t.string :uuid
      t.string :address
      t.integer :created_by
      t.integer :status
      t.text :context

      t.timestamps
    end

    add_index "rdvs", ["created_by"]
    add_index "rdvs", ["status"]
    add_index "rdvs", ["rdv_solidarites_rdv_id"], unique: true
  end
  # rubocop:enable Metrics/AbcSize
end
