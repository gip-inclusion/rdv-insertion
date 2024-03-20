class SendInvitationRemindersJob < ApplicationJob
  def perform
    @sent_reminders_user_ids = []

    rdv_contexts_with_reminder_needed.find_each do |rdv_context|
      invitation = rdv_context.first_invitation_relative_to_last_participation
      # we check here that the **first** invitation has been sent Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER
      # number of days ago with that value being set to 3
      next unless invitation_sent_3_days_ago?(invitation)
      next if invitation_related_to_archive?(invitation)

      user = rdv_context.user

      SendInvitationReminderJob.perform_async(rdv_context.id, "email") if user.email?
      SendInvitationReminderJob.perform_async(rdv_context.id, "sms") if user.phone_number_is_mobile?

      @sent_reminders_user_ids << user.id
    end

    notify_on_mattermost
  end

  private

  def rdv_contexts_with_reminder_needed
    @rdv_contexts_with_reminder_needed ||=
      RdvContext.invitation_pending
                .joins(:motif_category)
                .where(motif_category: MotifCategory.optional_rdv_subscription(false))
                .where(id: valid_invitations_sent_3_days_ago.pluck(:rdv_context_id))
                .where(user_id: User.active.select(:id))
                .distinct
  end

  def valid_invitations_sent_3_days_ago
    @valid_invitations_sent_3_days_ago ||=
      # we want the token to be valid for at least two days to be sure the invitation will be valid
      Invitation.where("valid_until > ?", 2.days.from_now)
                .where(
                  format: %w[email sms],
                  created_at: Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.all_day,
                  reminder: false
                )
  end

  def invitation_sent_3_days_ago?(invitation)
    invitation.created_at.to_date == Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.to_date
  end

  def invitation_related_to_archive?(invitation)
    Archive.exists?(user: invitation.user, department: invitation.department)
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_reminders_user_ids.length} relances en cours!\n" \
      "Les usagers sont: #{@sent_reminders_user_ids}"
    )
  end
end
