class DeleteRdvJob < ApplicationJob
  def perform(rdv_solidarites_rdv_id)
    rdv = Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
    return unless rdv

    follow_up_ids = rdv.follow_up_ids
    rdv.destroy!
    FollowUp::RefreshStatusesJob.perform_later(follow_up_ids)
  end
end
