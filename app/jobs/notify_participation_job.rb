class NotificationsJobError < StandardError; end

class NotifyParticipationJob < ApplicationJob
  def perform(participation_id, format, event)
    @participation = Participation.find(participation_id)
    @format = format
    @event = event

    return if user.created_through_rdv_solidarites? && user.invitations.sent.empty?

    Notification.with_advisory_lock "notifying_particpation_#{@participation.id}" do
      return if already_notified?

      notify_participation!
    end
  end

  private

  def user
    @participation.user
  end

  def already_notified?
    if @event == "participation_updated"
      # we assume here there should not be more than 2 lieu/time updates in one hour. The mattermost notification
      # would let us double check anyway.
      @participation.notifications.sent
                    .where(event: "participation_updated", format: @format)
                    .where("sent_at > ?", 1.hour.ago).count > 1
    else
      @participation.notifications.sent.find_by(event: @event, format: @format).present?
    end
  end

  def notify_participation!
    raise NotificationsJobError, notify_participation.errors.join(" - ") unless notify_participation.success?
  end

  def notify_participation
    @notify_participation ||= Notifications::NotifyParticipation.call(
      participation: @participation, format: @format, event: @event
    )
  end
end
