class RenameUnavailableCreneauLogsToBlockedInvitationsCounters < ActiveRecord::Migration[8.0]
  def change
    rename_table :blocked_invitations_counters, :blocked_invitations_counters
  end
end
