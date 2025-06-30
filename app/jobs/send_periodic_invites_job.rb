class SendPeriodicInvitesJob < ApplicationJob
  def perform
    @sent_invites_user_ids = []

    FollowUp
      .joins(:invitations)
      .preload(invitations: [{ organisations: :category_configurations }, :user])
      .where(invitations: Invitation.candidates_for_periodic_invite)
      .distinct
      .find_each do |follow_up|
      send_invite(follow_up)
    end

    notify_on_mattermost
  end

  private

  def send_invite(follow_up)
    last_invitation = follow_up.last_invitation

    return unless last_invitation.should_be_sent_again_as_periodic_invite?

    @sent_invites_user_ids << last_invitation.user.id

    %w[email sms].each do |format|
      next unless last_invitation.user.can_be_invited_through?(format)

      SendPeriodicInviteJob.perform_later(last_invitation.id, format)
    end
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_invites_user_ids.length} invitations périodiques envoyées!\n" \
      "Les usagers sont: #{@sent_invites_user_ids}"
    )
  end
end
