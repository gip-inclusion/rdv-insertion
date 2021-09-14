class NotificationsJobError < StandardError; end

class NotifyApplicantJob < ApplicationJob
  def perform(applicant_id, lieu, motif, starts_at, event)
    @applicant_id = applicant_id
    @lieu = lieu&.deep_symbolize_keys
    @motif = motif.deep_symbolize_keys
    @starts_at = starts_at
    @event = event

    raise NotificationsJobError, notify_applicant.errors.join(" - ") unless notify_applicant.success?
  end

  private

  def applicant
    @applicant ||= Applicant.includes(:department).find(@applicant_id)
  end

  def notify_applicant
    service_class = service_class_for_event_type(@event)
    service_class.call(
      applicant: applicant, lieu: @lieu, motif: @motif, starts_at: @starts_at
    )
  end

  def service_class_for_event_type(event_type)
    {
      "created" => Notifications::RdvCreated,
      "updated" => Notifications::RdvUpdated,
      "destroyed" => Notifications::RdvCancelled
    }[event_type]
  end
end
