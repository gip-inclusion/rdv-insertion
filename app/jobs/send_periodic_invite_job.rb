class SendPeriodicInviteJob < ApplicationJob
  def perform(invitation_id, category_configuration_id, format)
    @invitation = Invitation.find(invitation_id)
    @category_configuration = CategoryConfiguration.find(category_configuration_id)
    @format = format

    return if invitation_already_sent_today?
    return unless creneaux_available_for_invitation?

    send_invitation
  end

  private

  def send_invitation
    new_invitation = @invitation.dup

    new_invitation.format = @format
    new_invitation.trigger = "periodic"
    new_invitation.expires_at = @category_configuration.new_invitation_will_expire_at
    new_invitation.organisations = @invitation.organisations
    new_invitation.uuid = nil
    new_invitation.save!

    Invitations::SaveAndSend.call(invitation: new_invitation, check_creneaux_availability: false)
  end

  def creneaux_available_for_invitation?
    @category_configuration.organisation.agents.first.with_rdv_solidarites_session do
      params = @invitation.link_params.merge(post_code: @invitation.user.parsed_post_code).symbolize_keys
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
    end
  end

  def invitation_already_sent_today?
    @invitation.follow_up.invitations
               .where(format: @format)
               .where("created_at > ?", 24.hours.ago)
               .any?
  end
end
