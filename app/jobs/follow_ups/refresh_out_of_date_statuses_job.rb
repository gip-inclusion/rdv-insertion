class FollowUps::RefreshOutOfDateStatusesJob < ApplicationJob
  def perform
    @follow_up_ids = []
    updatable_follow_ups.find_each do |follow_up|
      @follow_up_ids << follow_up.id if follow_up.status != follow_up.compute_status.to_s
    end

    notify_on_slack
    FollowUps::RefreshStatusesJob.perform_later(@follow_up_ids)
  end

  private

  def notify_on_slack
    SlackClient.send_to_notif_channel(
      "✨ Rafraîchit les statuts pour: #{@follow_up_ids}"
    )
  end

  def updatable_follow_ups
    FollowUp.includes(:invitations, participations: :rdv)
            .where(user_id: User.active.select(:id))
            .where.not(status: %w[closed not_invited])
            .distinct
  end
end
