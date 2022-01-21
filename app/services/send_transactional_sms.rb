class SendTransactionalSms < BaseService
  def initialize(phone_number_formatted:, sender_name:, content:)
    @sender_name = sender_name
    @phone_number_formatted = phone_number_formatted
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
    Sentry.capture_exception(
      e,
      extra: {
        response_body: e.response_body,
        phone_number: @phone_number_formatted,
        content: formatted_content
      }
    )
    fail!("une erreur est survenue en envoyant le sms. #{e.message}")
  end

  def transactional_sms
    SibApiV3Sdk::SendTransacSms.new(
      sender: @sender_name,
      recipient: @phone_number_formatted,
      content: formatted_content,
      type: "transactional"
    )
  end

  def formatted_content
    @content.tr("áâãëẽêíïîĩóôõúûũçÀÁÂÃÈËẼÊÌÍÏÎĨÒÓÔÕÙÚÛŨ", "aaaeeeiiiiooouuucAAAAEEEEIIIIIOOOOUUUU")
  end
end
