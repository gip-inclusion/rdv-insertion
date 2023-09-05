class MonitorWebhookActivityJob < ApplicationJob
  MONITORED_MODELS = [
    AgentRole,
    Agent,
    Applicant,
    Lieu,
    Motif,
    Organisation,
    Rdv
  ].freeze

  def perform
    alertable_models = MONITORED_MODELS.select do |model|
      model.where("last_webhook_update_received_at > ?", 24.hours.ago).empty?
    end

    return if alertable_models.empty?

    MattermostClient.send_to_notif_channel(
      "⚠️ Pas de webhook reçus dans les dernières 24 heures pour les models suivants : \n" \
      "#{alertable_models.map(&:name).join(', ')}"
    )
  end
end
