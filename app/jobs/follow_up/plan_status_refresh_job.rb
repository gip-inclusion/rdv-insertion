class FollowUp::PlanStatusRefreshJob < ApplicationJob
  include LockedJobs

  def self.lock_key(follow_up_id)
    "#{base_lock_key}:#{follow_up_id}"
  end

  def perform(follow_up_id)
    follow_up = FollowUp.find(follow_up_id)
    return if follow_up.refresh_status_at.blank?

    Sidekiq::Scheduler.schedule_uniq_job(
      FollowUp::RefreshStatusesJob, follow_up.id,
      at: follow_up.refresh_status_at
    )
  end
end
