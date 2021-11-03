class NotificationsJobError < StandardError; end

class NotifyApplicantJob < ApplicationJob
  def perform(applicant_id, organisation_id, rdv_attributes, event)
    @applicant_id = applicant_id
    @organisation_id = organisation_id
    @rdv_solidarites_rdv = RdvSolidarites::Rdv.new(rdv_attributes)
    @event = event

    return send_already_notified_to_mattermost if already_notified?
    raise NotificationsJobError, notify_applicant.errors.join(" - ") unless notify_applicant.success?
  end

  private

  def applicant
    @applicant ||= Applicant.find(@applicant_id)
  end

  def organisation
    @organisation ||= Organisation.find(@organisation_id)
  end

  def already_notified?
    Notification.find_by(rdv_solidarites_rdv_id: @rdv_solidarites_rdv.id, event: "rdv_#{@event}")&.sent_at.present?
  end

  def send_already_notified_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Rdv already notified to applicant. Skipping notification sending.\n" \
      "rdv_solidarites_rdv_id: #{@rdv_solidarites_rdv.id} - event: rdv_#{@event} - " \
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
