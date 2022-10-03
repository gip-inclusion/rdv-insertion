class NotificationsJobError < StandardError; end

class NotifyApplicantJob < ApplicationJob
  def perform(rdv_id, applicant_id, format, event)
    @rdv = Rdv.find(rdv_id)
    @applicant = Applicant.find(applicant_id)
    @format = format
    @event = event

    Rdv.with_advisory_lock "notifying_for_rdv_#{@rdv_solidarites_rdv.id}" do
      return send_already_notified_to_mattermost if already_notified?
      raise NotificationsJobError, notify_applicant.errors.join(" - ") unless notify_applicant.success?
    end
  end

  private

  def already_notified?
    if @event == "rdv_updated"
      # we assume here there should not be more than 2 lieu/time updates in one hour. The mattermost notification
      # would let us double check anyway.
      @rdv.sent_notifications.where(event: "rdv_updated").where("sent_at > ?", 1.hour.ago).count > 1
    else
      @rdv.sent_notifications.find_by(event: @event).present?
    end
  end

  def send_already_notified_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Rdv already notified to applicant. Skipping notification sending.\n" \
      "rdv id: #{@rdv.id} " \
      "applicant_id: #{@applicant_id}"
    )
  end

  def notify_applicant
    service_class = service_class_for_event_type(@event)
    service_class.call(
      applicant: applicant, organisation:  organisation,
      rdv_solidarites_rdv: @rdv_solidarites_rdv
    )
  end

  def service_class_for_event_type(event_type)
    {
      "created" => Notifications::RdvCreated,
      "destroyed" => Notifications::RdvCancelled
    }[event_type]
  end
end
