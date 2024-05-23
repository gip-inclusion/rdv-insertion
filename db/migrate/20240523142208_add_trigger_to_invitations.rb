class AddTriggerToInvitations < ActiveRecord::Migration[7.1]
  def up
    add_column :invitations, :trigger, :string, null: false, default: "manual"

    # migrate existing invitations reminder boolean to trigger 'reminder'
    Invitation.where(reminder: true).update_all(trigger: "reminder")

    remove_column :invitations, :reminder, :boolean
  end

  def down
    add_column :invitations, :reminder, :boolean, default: false

    Invitation.where(trigger: "reminder").update_all(reminder: true)

    remove_column :invitations, :trigger, :string
  end
end
