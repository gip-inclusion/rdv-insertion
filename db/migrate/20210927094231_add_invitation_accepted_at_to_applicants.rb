class AddInvitationAcceptedAtToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :invitation_accepted_at, :date
  end
end
