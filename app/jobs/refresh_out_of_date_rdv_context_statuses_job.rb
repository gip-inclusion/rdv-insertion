class RefreshOutOfDateRdvContextStatusesJob < ApplicationJob
  def perform
    @rdv_context_ids = []
    RdvContext.find_each do |rdv_context|
      @rdv_context_ids << rdv_context.id if rdv_context.status != rdv_context.set_status.to_s
    end

    notify_on_mattermost
    RefreshRdvContextStatusesJob.perform_async(@rdv_context_ids)
  end

  private

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "✨ Rafraîchit les statuts pour: #{@rdv_context_ids}"
    )
  end
end
