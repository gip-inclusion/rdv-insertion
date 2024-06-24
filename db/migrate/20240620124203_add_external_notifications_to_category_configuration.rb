class AddExternalNotificationsToCategoryConfiguration < ActiveRecord::Migration[7.1]
  def change
    add_column :category_configurations, :notify_rdv_taken, :boolean, default: false
    add_column :category_configurations, :notify_rdv_taken_email, :string
    add_column :category_configurations, :notify_out_of_slots, :boolean, default: false
    add_column :category_configurations, :notify_out_of_slots_email, :string
  end
end
