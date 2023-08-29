class SendPeriodicInviteJob < ApplicationJob
  def perform(invitation_id, configuration_id, format)
    invitation = Invitation.find(invitation_id)
    configuration = Configuration.find(configuration_id)
    new_invitation = invitation.dup

    new_invitation.format = format
    new_invitation.reminder = false
    new_invitation.sent_at = nil
    new_invitation.valid_until = configuration.number_of_days_before_action_required.days.from_now
    new_invitation.organisations = invitation.organisations
    new_invitation.assign_uuid
    new_invitation.save!

    Invitations::SaveAndSend.call(invitation: new_invitation)
  end
end
