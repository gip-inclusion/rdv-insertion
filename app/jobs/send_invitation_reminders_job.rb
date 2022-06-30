class SendInvitationRemindersJob < ApplicationJob
  def perform # rubocop:disable Metrics/AbcSize
    return if staging_env?

    @sent_reminders_applicant_ids = []

    applicants_to_send_reminders_to.find_each do |applicant|
      # we check here that it is the **first** invitation that has been sent 3 days ago
      next if applicant.relevant_first_invitation_sent_at.to_date != 3.days.ago.to_date

      SendInvitationReminderJob.perform_async(applicant.id, "email") if applicant.email?
      SendInvitationReminderJob.perform_async(applicant.id, "sms") if applicant.phone_number?
      @sent_reminders_applicant_ids << applicant.id
    end

    notify_on_mattermost
  end

  private

  def applicants_to_send_reminders_to
    @applicants_to_send_reminders_to ||= \
      Applicant.active
               .archived(false)
               .where(id: valid_invitations_sent_3_days_ago.pluck(:applicant_id))
               .distinct
  end

  def staging_env?
    ENV["SENTRY_ENVIRONMENT"] == "staging"
  end

  def valid_invitations_sent_3_days_ago
    @valid_invitations_sent_3_days_ago ||= \
      # we want the token to be valid for at least two days to be sure the invitation will be valid
      Invitation.where("valid_until > ?", 2.days.from_now)
                .where(format: %w[email sms], sent_at: 3.days.ago.all_day)
                .joins(:rdv_context)
                .where(rdv_contexts: { status: "invitation_pending" })
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📬 #{@sent_reminders_applicant_ids.length} relances en cours!\n" \
      "Les allocataires sont: #{@sent_reminders_applicant_ids}"
    )
  end
end
