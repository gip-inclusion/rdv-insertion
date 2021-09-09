class AddSeenToInvitations < ActiveRecord::Migration[6.1]
  def change
    add_column :invitations, :seen, :boolean, default: false
  end
end
