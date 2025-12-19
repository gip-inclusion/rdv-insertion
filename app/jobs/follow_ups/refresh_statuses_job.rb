class FollowUps::RefreshStatusesJob < ApplicationJob
  def perform(follow_up_ids)
    follow_ups = FollowUp.includes(:invitations, :rdvs).where(id: follow_up_ids)
    follow_ups.each do |follow_up|
      follow_up.set_status
      follow_up.save!
    end
  end
end
