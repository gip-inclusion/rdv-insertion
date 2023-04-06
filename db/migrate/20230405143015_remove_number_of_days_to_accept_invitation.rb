class RemoveNumberOfDaysToAcceptInvitation < ActiveRecord::Migration[7.0]
  def change
    remove_column :invitations, :number_of_days_to_accept_invitation, :integer, default: 3
    remove_column :configurations, :number_of_days_to_accept_invitation, :integer, default: 3
  end
end
