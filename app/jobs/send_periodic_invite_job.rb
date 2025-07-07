class SendPeriodicInviteJob < ApplicationJob
  def perform(previous_invitation_id, format)
    @previous_invitation = Invitation.find(previous_invitation_id)
    @format = format

    return alert_non_eligible_periodic_invite unless @previous_invitation.should_be_sent_again_as_periodic_invite?

    save_and_send_invitation if creneaux_available_for_invitation?
  end

  private

  def save_and_send_invitation
    call_service!(Invitations::SaveAndSend, invitation: new_invitation, check_creneaux_availability: false)
  end

  def new_invitation
    @new_invitation ||= Invitation.new(
      trigger: "periodic",
      user: @previous_invitation.user,
      department: @previous_invitation.department,
      organisations: @previous_invitation.organisations,
      follow_up: @previous_invitation.follow_up,
      format: @format,
      help_phone_number: @previous_invitation.help_phone_number,
      rdv_solidarites_lieu_id: @previous_invitation.rdv_solidarites_lieu_id,
      link: @previous_invitation.link,
      rdv_solidarites_token: @previous_invitation.rdv_solidarites_token,
      expires_at: nil,
      rdv_with_referents: @previous_invitation.rdv_with_referents
    )
  end

  # Creneaux availability check is done here and not in the service Invitations::SaveAndSend because:
  # - we don't want the service to fail if the creneaux are not available
  # - we want to cache the result for similar invitations params to avoid calling the API too often
  def creneaux_available_for_invitation?
    params = @previous_invitation.link_params.symbolize_keys.slice(
      :motif_category_short_name,
      :departement,
      :organisation_ids,
      :referent_ids
    )

    Rails.cache.fetch("RetrieveCreneauAvailability/#{params.sort.to_h.to_query}", expires_in: 12.hours) do
      @previous_invitation.organisations.active.first.agents.first.with_rdv_solidarites_session do
        RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
      end
    end
  end

  def alert_non_eligible_periodic_invite
    Sentry.capture_message(
      "Invitation périodique non envoyée pour l'utilisateur #{@previous_invitation.user.id} en rapport à " \
      "l'invitation #{@previous_invitation.id} car non éligible"
    )
  end
end
