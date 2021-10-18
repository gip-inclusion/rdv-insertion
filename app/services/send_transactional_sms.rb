class SendTransactionalSms < BaseService
  SENDER_NAME = "RdvRSA".freeze

  def initialize(phone_number:, content:)
    @phone_number = phone_number
    @content = content
  end

  def call
    send_transactional_sms
  end

  private

  def send_transactional_sms
    api_instance = SibApiV3Sdk::TransactionalSMSApi.new
    api_instance.send_transac_sms(transactional_sms)
  rescue SibApiV3Sdk::ApiError => e
    Sentry.capture_exception(e, extra: { response_body: e.response_body, phone_number: @phone_number })
    fail!("une erreur est survenue en envoyant le sms. #{e.message}")
  end

  def transactional_sms
    SibApiV3Sdk::SendTransacSms.new(
      sender: SENDER_NAME,
      recipient: @phone_number,
      content: formatted_content,
      type: "transactional"
    )
  end

  def formatted_content
    @content.tr("áâãëẽêíïîĩóôõúûũçÀÁÂÃÈËẼÊÌÍÏÎĨÒÓÔÕÙÚÛŨ", "aaaeeeiiiiooouuucAAAAEEEEIIIIIOOOOUUUU")
  end
end
