class SendPeriodicInviteJob < ApplicationJob
  def perform(invitation_id, category_configuration_id, format)
    @invitation = Invitation.find(invitation_id)
    @category_configuration = CategoryConfiguration.find(category_configuration_id)
    @format = format

    return if invitation_already_sent_today?

    send_invitation
  end

  private

  def send_invitation
    new_invitation = @invitation.dup

    new_invitation.format = @format
    new_invitation.trigger = "periodic"
    new_invitation.expires_at = @category_configuration.invitation_duration_in_days.days.from_now
    new_invitation.organisations = @invitation.organisations
    new_invitation.uuid = nil
    new_invitation.save!

    Invitations::SaveAndSend.call(invitation: new_invitation, check_creneaux_availability: false)
  end

  def invitation_already_sent_today?
    @invitation.follow_up.invitations
               .where(format: @format)
               .where("created_at > ?", 24.hours.ago)
               .any?
  end
end
