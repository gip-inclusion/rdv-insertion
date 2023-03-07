class MattermostClient
  class << self
    def send_to_notif_channel(text)
      send_message(ENV["MATTERMOST_NOTIFICATIONS_WEBHOOKS_URL"], text)
    end

    def send_to_bug_channel(text)
      send_message(ENV["MATTERMOST_BUG_WEBHOOKS_URL"], text)
    end

    private

    def send_message(url, text)
      return unless Rails.env.production?

      Faraday.post(
        url,
        { text: text }.to_json,
        { "Content-Type" => "application/json" }
      )
    end
  end
end
