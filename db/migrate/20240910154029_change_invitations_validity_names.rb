class ChangeInvitationsValidityNames < ActiveRecord::Migration[7.1]
  def change
    rename_column :invitations, :valid_until, :expires_at
    rename_column :category_configurations, :number_of_days_before_action_required, :invitation_duration_in_days
    add_index :invitations, :expires_at
  end
end
