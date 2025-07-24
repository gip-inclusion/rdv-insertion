class MonitorInboundEmailsActivityJob < ApplicationJob
  def perform
    return if inbound_email_received_less_than_7_days_ago?

    MattermostClient.send_to_private_channel(
      "⚠️ Les emails des usagers n'ont pas été transérés depuis plus de 7 jours!\n" \
      "Dernier email reçu le #{last_inbound_email_received_at.strftime('%d/%m/%Y %H:%M')}"
    )
  end

  private

  def last_inbound_email_received_at
    RedisConnection.with_redis do |redis|
      Time.zone.at(redis.get("last_inbound_email_received_at").to_i)
    end
  end

  def inbound_email_received_less_than_7_days_ago?
    last_inbound_email_received_at > 7.days.ago
  end
end
