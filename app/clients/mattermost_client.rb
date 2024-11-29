class MattermostClient
  class << self
    EXPIRATION = 24.hours.to_i

    def send_to_notif_channel(text, once_a_day: false)
      return if once_a_day && !should_send_daily_message?(text)

      send_message(ENV["MATTERMOST_NOTIFICATIONS_CHANNEL_URL"], text)
      update_last_sent_timestamp(text) if once_a_day
    end

    def send_to_main_channel(text, once_a_day: false)
      return if once_a_day && !should_send_daily_message?(text)

      send_message(ENV["MATTERMOST_MAIN_CHANNEL_URL"], text)
      update_last_sent_timestamp(text) if once_a_day
    end

    def send_to_private_channel(text, once_a_day: false)
      return if once_a_day && !should_send_daily_message?(text)

      send_message(ENV["MATTERMOST_PRIVATE_CHANNEL_URL"], text)
      update_last_sent_timestamp(text) if once_a_day
    end

    private

    def send_message(url, text)
      return unless ENV["ENVIRONMENT_NAME"] == "production"

      Faraday.post(
        url,
        { text: text }.to_json,
        { "Content-Type" => "application/json" }
      )
    end

    def redis_key(text)
      "mattermost_daily_message:#{Digest::MD5.hexdigest(text)}"
    end

    def should_send_daily_message?(text)
      !REDIS.exists?(redis_key(text))
    end

    def update_last_sent_timestamp(text)
      REDIS.set(redis_key(text), Time.current.to_i, ex: EXPIRATION)
    end
  end
end
