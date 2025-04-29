class AddDisableFtWebhooksToDepartment < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :disable_ft_webhooks, :boolean, default: false
  end
end
