class RemoveContextsFromInvitations < ActiveRecord::Migration[6.1]
  def change
    remove_column :invitations, :context, :string
  end
end
