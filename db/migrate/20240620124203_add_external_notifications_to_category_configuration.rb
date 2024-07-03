class AddExternalNotificationsToCategoryConfiguration < ActiveRecord::Migration[7.1]
  def change
    add_column :category_configurations, :email_to_notify_no_available_slots, :string
    add_column :category_configurations, :email_to_notify_rdv_changes, :string
  end
end
