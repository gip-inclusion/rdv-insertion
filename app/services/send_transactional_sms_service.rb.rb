class SendTransactionalSmsService < BaseService
  def initialize(phone:, message:)
    @phone = phone
    @message = message
    @url = URI("https://api.sendinblue.com/v3/transactionalSMS/sms")
    @sender_name = "Rdv RSA"
  end

  def perform
    send("send_with_send_in_blue")
  end

  private

  def send_with_send_in_blue
    config = SibApiV3Sdk::Configuration.new
    config.api_key = ENV['SENDINBLUE_API_V3_KEY']
    api_client = SibApiV3Sdk::ApiClient.new(config)
    SibApiV3Sdk::TransactionalSMSApi.new(api_client).send_transac_sms(
      SibApiV3Sdk::SendTransacSms.new(
        sender: @sender_name,
        recipient: @phone,
        content: @message,
        type: "transactional"
      )
    )
  end
end
