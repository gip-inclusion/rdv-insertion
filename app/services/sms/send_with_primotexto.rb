module Sms
  class SendWithPrimotexto < BaseService
    def initialize(phone_number:, sender_name:, content:)
      @sender_name = sender_name
      @phone_number = phone_number
      @content = content
    end

    def call
      send_sms
    end

    private

    def send_sms
      return if primotexto_response.success?

      fail!("une erreur est survenue en envoyant le sms via Primotexto: #{primotexto_response.body}")
    end

    def primotexto_response
      @primotexto_response ||= PrimotextoClient.send_sms(
        phone_number: @phone_number, sender_name: @sender_name, content: @content
      )
    end
  end
end
