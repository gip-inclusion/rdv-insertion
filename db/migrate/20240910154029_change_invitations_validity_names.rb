class ChangeInvitationsValidityNames < ActiveRecord::Migration[7.1]
  def change
    rename_column :invitations, :valid_until, :expires_at
    rename_column :category_configurations, :number_of_days_before_action_required,
                  :number_of_days_before_invitations_expire
    add_index :invitations, :expires_at
  end
end
