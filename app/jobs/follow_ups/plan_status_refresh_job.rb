class FollowUps::PlanStatusRefreshJob < ApplicationJob
  def perform(follow_up_id)
    follow_up = FollowUp.find(follow_up_id)
    return if follow_up.refresh_status_at.blank? || follow_up.refresh_status_at < Time.zone.now

    Sidekiq::Scheduler.schedule_uniq_job(
      FollowUps::RefreshStatusesJob, follow_up.id,
      at: follow_up.refresh_status_at
    )
  end
end
