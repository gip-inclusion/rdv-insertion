class AddCreatedByAgentToInvitations < ActiveRecord::Migration[8.1]
  def change
    add_reference :invitations, :created_by_agent, null: true, foreign_key: { to_table: :agents }
  end
end
