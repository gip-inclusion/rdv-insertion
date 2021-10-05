class DeleteRdvJob < ApplicationJob
  def perform(rdv_solidarites_rdv_id)
    rdv = Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
    return unless rdv

    applicant_ids = rdv.applicant_ids
    rdv.destroy!
    RefreshApplicantStatusesJob.perform_async(applicant_ids)
  end
end
