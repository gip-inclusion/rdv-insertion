class CarnetDeBordClient
  API_TOKEN = ENV["CARNET_DE_BORD_API_SECRET"]
  CARNET_DE_BORD_URL = ENV["CARNET_DE_BORD_URL"]

  class << self
    def create_carnet(payload)
      Faraday.post(
        "#{CARNET_DE_BORD_URL}/api/notebooks",
        payload.to_json,
        request_headers
      )
    end

    private

    def request_headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{API_TOKEN}"
      }
    end
  end
end
