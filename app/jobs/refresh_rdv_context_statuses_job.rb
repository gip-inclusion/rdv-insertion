class RefreshRdvContextStatusesJob < ApplicationJob
  def perform(context_ids)
    @context_ids = context_ids
    rdv_contexts.each do |rdv_context|
      rdv_context.set_status
      rdv_context.save!
    end
  end

  private

  def rdv_contexts
    RdvContext.includes(:invitations, :rdvs).where(id: @context_ids)
  end
end
