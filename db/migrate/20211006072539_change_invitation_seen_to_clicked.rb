class ChangeInvitationSeenToClicked < ActiveRecord::Migration[6.1]
  def change
    rename_column :invitations, :seen, :clicked
  end
end
