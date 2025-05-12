class PrimotextoClient
  SEND_SMS_URL = "https://api.primotexto.com/v2/notification/messages/send".freeze

  class << self
    def send_sms(phone_number:, sender_name:, content:)
      Faraday.post(
        SEND_SMS_URL,
        {
          number: phone_number,
          sender: sender_name,
          message: content
        }.to_json,
        headers
      )
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "X-Primotexto-ApiKey" => ENV["PRIMOTEXTO_API_KEY"]
      }
    end
  end
end
