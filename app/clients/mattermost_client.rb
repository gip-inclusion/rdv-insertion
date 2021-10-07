class MattermostClient
  class << self
    def send_to_notif_channel(text)
      return unless Rails.env.production?

      Faraday.post(
        ENV['MATTERMOST_WEBHOOKS_URL'],
        { text: text }.to_json,
        { "Content-Type" => "application/json" }
      )
    end
  end
end
