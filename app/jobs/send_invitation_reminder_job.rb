class SendInvitationReminderJobError < StandardError; end

class SendInvitationReminderJob < ApplicationJob
  def perform(rdv_context_id, invitation_format)
    @rdv_context = RdvContext.find(rdv_context_id)
    @applicant = @rdv_context.applicant
    @invitation_format = invitation_format

    return if invitation_already_sent_today?

    return notify_non_eligible_for_reminder unless eligible_for_reminder?

    return if save_and_send_invitation.success?

    raise SendInvitationReminderJobError, save_and_send_invitation.errors.join(", ")
  end

  private

  def invitation
    @invitation ||= Invitation.new(
      reminder: true,
      applicant: @applicant,
      department: first_invitation.department,
      organisations: first_invitation.organisations,
      rdv_context: first_invitation.rdv_context,
      format: @invitation_format,
      help_phone_number: first_invitation.help_phone_number,
      rdv_solidarites_lieu_id: first_invitation.rdv_solidarites_lieu_id,
      link: first_invitation.link,
      rdv_solidarites_token: first_invitation.rdv_solidarites_token,
      valid_until: first_invitation.valid_until,
      rdv_with_referents: first_invitation.rdv_with_referents
    )
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(invitation: invitation)
  end

  def invitation_already_sent_today?
    @rdv_context.invitations.where(format: @invitation_format).where("sent_at > ?", 24.hours.ago).present?
  end

  def notify_non_eligible_for_reminder
    MattermostClient.send_to_notif_channel(
      "🚫 L'allocataire #{@applicant.id} n'est pas éligible à la relance pour #{@rdv_context.motif_category_name}."
    )
  end

  def eligible_for_reminder?
    @rdv_context.status == "invitation_pending" &&
      first_invitation.sent_at.to_date == Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER.days.ago.to_date &&
      first_invitation.valid_until >= 2.days.from_now
  end

  def first_invitation
    @first_invitation ||= @rdv_context.first_invitation_relative_to_last_participation
  end
end
