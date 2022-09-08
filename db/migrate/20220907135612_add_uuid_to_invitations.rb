class AddUuidToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :uuid, :string
    add_index "invitations", ["uuid"], unique: true
  end
end
