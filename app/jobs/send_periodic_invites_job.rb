class SendPeriodicInvitesJob < ApplicationJob
  def perform
    return if staging_env?

    @sent_invites_applicant_ids = []

    RdvContext
      .joins(:motif_category, :invitations)
      .preload(invitations: [{ organisations: :configurations }, :applicant])
      .where(motif_categories: { participation_optional: true })
      .where(invitations: Invitation.valid.sent)
      .find_each do |rdv_context|
      send_invite(rdv_context)
    end

    notify_on_mattermost
  end

  def send_invite(rdv_context)
    last_sent_invitation = rdv_context.last_sent_invitation
    configuration = last_sent_invitation&.current_configuration

    return if configuration.blank?
    return unless should_send_periodic_invite?(last_sent_invitation, configuration)

    @sent_invites_applicant_ids << last_sent_invitation.applicant.id

    %w[email sms].each do |format|
      next unless last_sent_invitation.applicant.can_be_invited_through?(format)

      SendPeriodicInviteJob.perform_async(last_sent_invitation.id, configuration.id, format)
    end
  end

  def should_send_periodic_invite?(last_sent_invitation, configuration)
    return false if configuration.number_of_days_before_next_invite.blank?

    (Time.zone.today - last_sent_invitation.sent_at.to_date).to_i == configuration.number_of_days_before_next_invite
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_invites_applicant_ids.length} invitations périodiques envoyées!\n" \
      "Les allocataires sont: #{@sent_invites_applicant_ids}"
    )
  end
end
