class SendPeriodicInvitesJob < ApplicationJob
  def perform
    RdvContext
      .joins(:motif_category, :invitations)
      .preload(invitations: { organisations: :configurations })
      .where(motif_categories: { participation_optional: false })
      .where("invitations.valid_until < ?", Time.zone.now)
      .find_each do |rdv_context|
      send_invite(rdv_context)
    end
  end

  def send_invite(rdv_context)
    invitation = rdv_context.invitations.order(sent_at: :desc).first
    configuration = invitation.configurations.find_by!(motif_category: invitation.motif_category)

    return unless should_send_periodic_invite?(invitation, configuration)

    SendPeriodicInviteJob.perform_async(invitation.id, "email") if applicant.email?
    SendPeriodicInviteJob.perform_async(invitation.id, "sms") if applicant.phone_number_is_mobile?
  end

  def should_send_periodic_invite?(invitation, configuration)
    (Time.zone.today - invitation.sent_at.to_date).to_i == configuration.number_of_days_before_next_invite
  end
end
