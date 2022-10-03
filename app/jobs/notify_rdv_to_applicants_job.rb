class NotifyRdvToApplicantsJob < ApplicationJob
  def perform(rdv_id, event_to_notify)
    rdv = Rdv.find(rdv_id)
    notification_event = "rdv_#{event_to_notify}"
    rdv.applicants.each do |applicant|
      NotifyApplicantJob.perform_async(rdv_id, applicant.id, "sms", notification_event) if applicant.phone_number_is_mobile?
      NotifyApplicantJob.perform_async(rdv_id, applicant.id, "email", notification_event) if applicant.email?
    end
  end
end
