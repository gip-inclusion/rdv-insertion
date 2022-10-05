class NotificationsJobError < StandardError; end

class NotifyRdvToApplicantJob < ApplicationJob
  def perform(rdv_id, applicant_id, format, event)
    @rdv = Rdv.find(rdv_id)
    @applicant = Applicant.find(applicant_id)
    @format = format
    @event = event

    Notification.with_advisory_lock "notifying_applicant_#{@applicant.id}_for_rdv_#{@rdv.id}" do
      return send_already_notified_to_mattermost if already_notified?

      notify_applicant!
    end
  end

  private

  def already_notified?
    if @event == "rdv_updated"
      # we assume here there should not be more than 2 lieu/time updates in one hour. The mattermost notification
      # would let us double check anyway.
      @rdv.notifications.sent.where(event: "rdv_updated", format: @format).where("sent_at > ?", 1.hour.ago).count > 1
    else
      @rdv.notifications.sent.find_by(event: @event, format: @format).present?
    end
  end

  def send_already_notified_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Rdv already notified to applicant. Skipping notification sending.\n" \
      "rdv id: #{@rdv.id} " \
      "applicant_id: #{@applicant.id}"
    )
  end

  def notify_applicant!
    raise NotificationsJobError, notify_applicant.errors.join(" - ") unless notify_applicant.success?
  end

  def notify_applicant
    @notify_applicant ||= Notifications::NotifyApplicant.call(
      rdv: @rdv, applicant: @applicant, format: @format, event: @event
    )
  end
end
