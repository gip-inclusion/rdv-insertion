class SendInvitationReminderJobError < StandardError; end

class SendInvitationReminderJob < ApplicationJob
  def perform(follow_up_id, invitation_format)
    @follow_up = FollowUp.find(follow_up_id)
    @user = @follow_up.user
    @invitation_format = invitation_format

    return if invitation_already_sent_today?

    return notify_non_eligible_for_reminder unless eligible_for_reminder?

    return if save_and_send_invitation.success?

    raise SendInvitationReminderJobError, save_and_send_invitation.errors.join(", ")
  end

  private

  def invitation
    @invitation ||= Invitation.new(
      trigger: "reminder",
      user: @user,
      department: last_manual_invitation.department,
      organisations: last_manual_invitation.organisations,
      follow_up: last_manual_invitation.follow_up,
      format: @invitation_format,
      help_phone_number: last_manual_invitation.help_phone_number,
      rdv_solidarites_lieu_id: last_manual_invitation.rdv_solidarites_lieu_id,
      link: last_manual_invitation.link,
      rdv_solidarites_token: last_manual_invitation.rdv_solidarites_token,
      expires_at: last_manual_invitation.expires_at,
      rdv_with_referents: last_manual_invitation.rdv_with_referents
    )
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(
      invitation:, check_creneaux_availability: false
    )
  end

  def invitation_already_sent_today?
    @follow_up
      .invitations
      .pending_or_delivered
      .where(format: @invitation_format)
      .where("created_at > ?", 24.hours.ago)
      .present?
  end

  def notify_non_eligible_for_reminder
    MattermostClient.send_to_notif_channel(
      "🚫 L'usager #{@user.id} n'est pas éligible à la relance pour #{@follow_up.motif_category_name}."
    )
  end

  def eligible_for_reminder?
    @follow_up.status == "invitation_pending" &&
      last_manual_invitation.created_at.to_date == Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.to_date &&
      last_manual_invitation.expireable? && last_manual_invitation.expires_at >= 2.days.from_now
  end

  def last_manual_invitation
    @last_manual_invitation ||= @follow_up.last_manual_invitation
  end
end
