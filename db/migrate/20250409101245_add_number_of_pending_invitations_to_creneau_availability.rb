class AddNumberOfPendingInvitationsToCreneauAvailability < ActiveRecord::Migration[8.0]
  def change
    add_column :creneau_availabilities, :number_of_pending_invitations, :integer
  end
end
