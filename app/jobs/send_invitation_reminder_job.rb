class SendInvitationReminderJobError < StandardError; end

class SendInvitationReminderJob < ApplicationJob
  def perform(applicant_id, invitation_format)
    @applicant = Applicant.find(applicant_id)
    @invitation_format = invitation_format

    return if invitation_already_sent_today?

    return notify_non_eligible_applicant unless eligible_applicant?

    return if save_and_send_invitation.success?

    raise SendInvitationReminderJobError, save_and_send_invitation.errors.join(", ")
  end

  private

  def invitation # rubocop:disable Metrics/AbcSize
    @invitation ||= Invitation.new(
      applicant: @applicant,
      department: first_invitation.department,
      organisations: first_invitation.organisations,
      rdv_context: first_invitation.rdv_context,
      format: @invitation_format,
      number_of_days_to_accept_invitation: first_invitation.number_of_days_to_accept_invitation,
      help_phone_number: first_invitation.help_phone_number,
      rdv_solidarites_lieu_id: first_invitation.rdv_solidarites_lieu_id,
      link: first_invitation.link,
      token: first_invitation.token,
      valid_until: first_invitation.valid_until
    )
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(invitation: invitation)
  end

  def invitation_already_sent_today?
    @applicant.invitations.where(format: @invitation_format).where("sent_at > ?", 24.hours.ago).present?
  end

  def notify_non_eligible_applicant
    MattermostClient.send_to_notif_channel(
      "🚫 L'allocataire #{@applicant.id} n'est pas éligible à la relance."
    )
  end

  def eligible_applicant?
    first_invitation.sent_at.to_date == 3.days.ago.to_date &&
      first_invitation.valid_until >= 2.days.from_now
  end

  def first_invitation
    @first_invitation ||= @applicant.relevant_first_invitation
  end
end
