class NotificationsJobError < StandardError; end

class NotifyParticipationJob < ApplicationJob
  def perform(participation_id, format, event)
    @participation = Participation.find(participation_id)
    @format = format
    @event = event

    Notification.with_advisory_lock "notifying_particpation_#{@participation.id}" do
      return send_already_notified_to_mattermost if already_notified?

      notify_participation!
    end
  end

  private

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

  def send_already_notified_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Rdv already notified to applicant. Skipping notification sending.\n" \
      "participation id: #{@participation.id}\n" \
      "format: #{@format}\n" \
      "event: #{@event}"
    )
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
