class ExpireInvitationJob < ApplicationJob
  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)
    invitation.expire!
  end
end
