class MonitorWebhookActivityJob < ApplicationJob
  MONITORS = [
    { acceptable_delay: 3.hours, model: Rdv },
    { acceptable_delay: 12.hours, model: User },
    { acceptable_delay: 12.hours, model: Agent },
    { acceptable_delay: 1.week, model: AgentRole },
    { acceptable_delay: 1.week, model: Lieu },
    { acceptable_delay: 1.week, model: Motif },
    { acceptable_delay: 1.week, model: Organisation }
  ].freeze

  def perform
    alertable_models = MONITORS.select do |monitor|
      monitor[:model].where("last_webhook_update_received_at > ?", monitor[:acceptable_delay].ago).empty?
    end

    return if alertable_models.empty?

    SlackClient.send_to_notif_channel(
      "⚠️ Les models suivants semblent ne pas avoir reçus de webhooks récemment : \n" \
      "#{alertable_models.pluck(:model).map(&:name).join(', ')}"
    )
  end
end
