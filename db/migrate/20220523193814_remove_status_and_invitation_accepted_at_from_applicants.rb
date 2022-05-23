class RemoveStatusAndInvitationAcceptedAtFromApplicants < ActiveRecord::Migration[6.1]
  def change
    remove_column :applicants, :status, :integer
    remove_column :applicants, :invitation_accepted_at, :date
  end
end
