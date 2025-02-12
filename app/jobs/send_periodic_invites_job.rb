class SendPeriodicInvitesJob < ApplicationJob
  def perform
    @sent_invites_user_ids = []

    FollowUp
      .joins(:invitations)
      .preload(invitations: [{ organisations: :category_configurations }, :user])
      .where(invitations: Invitation.valid)
      .distinct
      .find_each do |follow_up|
      send_invite(follow_up)
    end

    notify_on_mattermost
  end

  def send_invite(follow_up)
    last_invitation = follow_up.last_invitation
    category_configuration = last_invitation&.current_category_configuration

    return if category_configuration.blank?
    return unless should_send_periodic_invite?(last_invitation, category_configuration)
    return unless creneaux_available_for_invitation?(last_invitation, category_configuration)

    @sent_invites_user_ids << last_invitation.user.id

    %w[email sms].each do |format|
      next unless last_invitation.user.can_be_invited_through?(format)

      SendPeriodicInviteJob.perform_later(last_invitation.id, category_configuration.id, format)
    end
  end

  def should_send_periodic_invite?(last_invitation, category_configuration)
    if category_configuration.day_of_the_month_periodic_invites.present?
      Time.zone.today.day == category_configuration.day_of_the_month_periodic_invites &&
        # We don't send an invite the first month if the invitation was sent less than 10 days ago
        last_invitation.sent_before?(10.days.ago)
    elsif category_configuration.number_of_days_between_periodic_invites.present?
      (Time.zone.today - last_invitation.created_at.to_date).to_i ==
        category_configuration.number_of_days_between_periodic_invites
    else
      false
    end
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_invites_user_ids.length} invitations périodiques envoyées!\n" \
      "Les usagers sont: #{@sent_invites_user_ids}"
    )
  end

  def creneaux_available_for_invitation?(invitation, category_configuration)
    category_configuration.organisation.agents.first.with_rdv_solidarites_session do
      params = invitation.link_params.merge(post_code: invitation.user.parsed_post_code).symbolize_keys
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
    end
  end
end
