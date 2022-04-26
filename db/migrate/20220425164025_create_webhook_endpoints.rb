class CreateWebhookEndpoints < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_endpoints do |t|
      t.string :url
      t.string :secret

      t.timestamps
    end

    create_join_table :organisations, :webhook_endpoints do |t|
      t.index(
        [:organisation_id, :webhook_endpoint_id],
        unique: true,
        name: "index_webhook_orgas_on_orga_id_and_webhook_id"
      )
    end
  end
end
