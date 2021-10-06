class RefreshApplicantStatusesJob < ApplicationJob
  def perform(applicant_ids)
    @applicant_ids = applicant_ids
    applicants.each do |a|
      a.set_status
      a.save!
    end
  end

  private

  def applicants
    Applicant.includes(:invitations, :rdvs).where(id: @applicant_ids)
  end
end
