class ConveneRdvApplicantsJob < ApplicationJob
  def perform(rdv_id, event)
    rdv = Rdv.find(rdv_id)
    rdv.applicants.each do |applicant|
      ConveneApplicantJob.perform_async(applicant.id, "sms", event) if applicant.phone_number_is_mobile?
      ConveneApplicantJob.perform_async(applicant.id, "email", event) if applicant.email?
    end
  end
end
