class RenameUnavailableCreneauLogsToBlockedInvitationsCounters < ActiveRecord::Migration[8.0]
  def change
    rename_table :unavailable_creneau_logs, :blocked_invitations_counters
  end
end
