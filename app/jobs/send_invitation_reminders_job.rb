class SendInvitationRemindersJob < ApplicationJob
  def perform
    @sent_reminders_user_ids = []

    follow_ups_with_reminder_needed.includes(:invitations, :participations, :user).find_each do |follow_up|
      invitation = follow_up.last_manual_invitation
      # we check here that the reference invitation has been sent Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER
      # number of days ago with that value being set to 3
      next unless invitation_sent_3_days_ago?(invitation)

      user = follow_up.user

      SendInvitationReminderJob.perform_later(follow_up.id, "email") if user.email?
      SendInvitationReminderJob.perform_later(follow_up.id, "sms") if user.phone_number_is_mobile?

      @sent_reminders_user_ids << user.id
    end

    notify_on_mattermost
  end

  private

  def follow_ups_with_reminder_needed
    @follow_ups_with_reminder_needed ||=
      FollowUp.invitation_pending
              .where(id: valid_invitations_sent_3_days_ago.pluck(:follow_up_id))
              .where(user_id: User.active.select(:id))
              .distinct
  end

  def valid_invitations_sent_3_days_ago
    @valid_invitations_sent_3_days_ago ||=
      # We want the invitation to be valid for at least two days to give time to the user to accept the invitation.
      # We don't send reminders for invitations that never expire since we consider those as invitations
      # to optional rdvs.
      # We only send reminders for invitations that have been triggered manually and not by the system.
      Invitation.manual
                .where("expires_at > ?", 2.days.from_now)
                .where(
                  format: %w[email sms],
                  created_at: Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.all_day
                )
  end

  def invitation_sent_3_days_ago?(invitation)
    invitation.created_at.to_date == Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.to_date
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_reminders_user_ids.length} relances en cours!\n" \
      "Les usagers sont: #{@sent_reminders_user_ids}"
    )
  end
end
