class AddReminderToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :reminder, :boolean, default: false
  end
end
