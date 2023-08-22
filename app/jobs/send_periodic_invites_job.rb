class SendPeriodicInvitesJob < ApplicationJob
  def perform
    Invitation
      .valid
      .joins(rdv_context: :motif_category)
      .where(motif_categories: { participation_optional: false })
      .find_each do |invitation|
      SendPeriodicInviteJob.perform_async(invitation.id)
    end
  end
end
