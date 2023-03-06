class SendInvitationRemindersJob < ApplicationJob
  def perform
    return if staging_env?

    @sent_reminders_applicant_ids = []

    rdv_contexts_with_reminder_needed.find_each do |rdv_context|
      # we check here that it is the **first** invitation that has been sent 3 days ago
      next if rdv_context.first_invitation_relative_to_last_participation_sent_at.to_date != 3.days.ago.to_date

      applicant = rdv_context.applicant

      SendInvitationReminderJob.perform_async(rdv_context.id, "email") if applicant.email?
      SendInvitationReminderJob.perform_async(rdv_context.id, "sms") if applicant.phone_number_is_mobile?

      @sent_reminders_applicant_ids << applicant.id
    end

    notify_on_mattermost
  end

  private

  def rdv_contexts_with_reminder_needed
    @rdv_contexts_with_reminder_needed ||= \
      RdvContext.invitation_pending
                .joins(:motif_category)
                .where(motif_category: MotifCategory.participation_optional(false))
                .where(id: valid_invitations_sent_3_days_ago.pluck(:rdv_context_id))
                .where(applicant_id: Applicant.active.archived(false).ids)
                .distinct
  end

  def valid_invitations_sent_3_days_ago
    @valid_invitations_sent_3_days_ago ||= \
      # we want the token to be valid for at least two days to be sure the invitation will be valid
      Invitation.where("valid_until > ?", 2.days.from_now)
                .where(format: %w[email sms], sent_at: 3.days.ago.all_day, reminder: false)
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_reminders_applicant_ids.length} relances en cours!\n" \
      "Les allocataires sont: #{@sent_reminders_applicant_ids}"
    )
  end
end
