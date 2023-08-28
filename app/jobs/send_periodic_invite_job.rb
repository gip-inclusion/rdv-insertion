class SendPeriodicInviteJob < ApplicationJob
  def perform(invitation_id, format)
    new_invitation = Invitation.find(invitation_id).dup
    new_invitation.format = format
    new_invitation.reminder = false
    new_invitation.sent_at = nil

    Invitation::SaveAndSend.new(invitation: new_invitation).call
  end
end
