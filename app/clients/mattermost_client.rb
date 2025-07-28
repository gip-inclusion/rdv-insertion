class MattermostClient
  CHANNEL_URLS_BY_TYPE = {
    main: ENV["MATTERMOST_MAIN_CHANNEL_URL"],
    notification: ENV["MATTERMOST_NOTIFICATIONS_CHANNEL_URL"],
    private: ENV["MATTERMOST_PRIVATE_CHANNEL_URL"],
    sentry: ENV["MATTERMOST_SENTRY_CHANNEL_URL"],
    rgpd_cleanup: ENV["MATTERMOST_RGDP_CLEANUP_CHANNEL_URL"],
  }.freeze

  class << self
    def send_to_notif_channel(text)
      send_message(:notification, text)
    end

    def send_to_main_channel(text)
      send_message(:main, text)
    end

    def send_to_private_channel(text)
      send_message(:private, text)
    end

    def send_to_sentry_channel(text)
      send_message(:sentry, text)
    end

    def send_to_rgpd_cleanup_channel(text)
      send_message(:rgpd_cleanup, text)
    end

    def send_unique_message(channel_type:, text:, expiration: 24.hours)
      message_key = "mattermost_message:#{channel_type}:#{Digest::MD5.hexdigest(text)}"

      RedisConnection.with_redis do |redis|
        next if redis.exists?(message_key)

        send_message(channel_type, text)
        redis.set(message_key, Time.current.to_s, ex: expiration.to_i)
      end
    end

    def send_message(channel_type, text)
      url = CHANNEL_URLS_BY_TYPE.fetch(channel_type)
      send_http_request(url, text)
    end

    private

    def send_http_request(url, text)
      return unless ENV["ENVIRONMENT_NAME"] == "production"

      Faraday.post(
        url,
        { text: text }.to_json,
        { "Content-Type" => "application/json" }
      )
    end
  end
end
