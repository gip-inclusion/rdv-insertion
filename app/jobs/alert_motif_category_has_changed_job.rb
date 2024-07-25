class AlertMotifCategoryHasChangedJob < ApplicationJob
  attr_reader :motif

  def perform(motif_id)
    @motif = Motif.find_by(id: motif_id)

    return if motif&.rdvs.blank?

    alert_on_mattermost
    alert_on_sentry
  end

  private

  def alert_message
    @alert_message ||= "
      ⚠️ Le motif #{motif.name} (#{motif.id}) vient de changer
      de catégory malgré la présence de #{motif.rdvs.count} associés.
    "
  end

  def alert_on_mattermost
    MattermostClient.send_to_notif_channel(alert_message)
  end

  def alert_on_sentry
    Sentry.capture_message(alert_message)
  end
end
