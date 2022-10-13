class RenameTokenToRdvSolidaritesToken < ActiveRecord::Migration[7.0]
  def change
    rename_column :invitations, :token, :rdv_solidarites_token

    # we set a validity duration for invitations who have none, the last one being
    # sent 1 month ago
    up_only { Invitation.where(valid_until: nil).update_all(valid_until: 1.week.from_now) }
  end
end
