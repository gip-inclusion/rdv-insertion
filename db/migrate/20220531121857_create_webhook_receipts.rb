class CreateWebhookReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :webhook_receipts do |t|
      t.bigint :rdv_solidarites_rdv_id
      t.datetime :rdvs_webhook_timestamp
      t.datetime :sent_at
      t.references :webhook_endpoint, null: false, foreign_key: true

      t.timestamps
    end

    add_index "webhook_receipts", ["rdv_solidarites_rdv_id"], unique: true
  end
end
