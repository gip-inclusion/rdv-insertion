class AddDaysToAcceptInvitationsToConfiguationsAndInvitations < ActiveRecord::Migration[6.1]
  def change
    add_column :configurations, :number_of_days_to_accept_invitation, :integer, default: 3
    add_column :invitations, :number_of_days_to_accept_invitation, :integer

    up_only do
      Invitation.find_each do |invitation|
        invitation.update!(number_of_days_to_accept_invitation: 3)
      end
    end
  end
end
