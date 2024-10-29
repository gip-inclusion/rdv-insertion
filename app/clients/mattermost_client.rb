class MattermostClient
  class << self
    def send_to_notif_channel(text)
      send_message(ENV["MATTERMOST_NOTIFICATIONS_CHANNEL_URL"], text)
    end

    def send_to_main_channel(text)
      send_message(ENV["MATTERMOST_MAIN_CHANNEL_URL"], text)
    end

    def send_to_private_channel(text)
      send_message(ENV["MATTERMOST_PRIVATE_CHANNEL_URL"], text)
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
  end
end
