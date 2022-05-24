class DeleteRdvJob < ApplicationJob
  def perform(rdv_solidarites_rdv_id)
    rdv = Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
    return unless rdv

    rdv_context_ids = rdv.rdv_context_ids
    rdv.destroy!
    RefreshRdvContextStatusesJob.perform_async(rdv_context_ids)
  end
end
