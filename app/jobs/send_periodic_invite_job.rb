class SendPeriodicInviteJob < ApplicationJob
  def perform(invitation_id)
    Invitation
      .find(invitation_id)
      .organisations
      .find_each do |organisation|
      configuration = organisation.configurations.find_by!(motif_category: invitation.motif_category)

      if (Time.zone.today - invitation.sent_at.to_date).to_i == configuration.number_of_days_before_next_invite
        Invitation::SaveAndSend.new(invitation: invitation.dup).call
      end
    end
  end
end
