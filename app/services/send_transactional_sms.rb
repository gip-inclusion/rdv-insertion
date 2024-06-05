class SendTransactionalSms < BaseService
  def initialize(phone_number:, sender_name:, content:, invitation_id: nil)
    @sender_name = sender_name
    @phone_number = phone_number
    @content = content
    @invitation_id = invitation_id
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
        phone_number: @phone_number,
        content: formatted_content
      }
    )
    fail!("une erreur est survenue en envoyant le sms. #{e.message}")
  end

  def transactional_sms
    opts = {
      sender: @sender_name,
      recipient: @phone_number,
      content: formatted_content,
      type: "transactional"
    }
    if @invitation_id
      # Used to track the SMS invitation status with the brevo webhooks
      opts[:webUrl] =
        Rails.application.routes.url_helpers.brevo_sms_webhooks_url(@invitation_id, host: ENV["HOST"])
    end

    SibApiV3Sdk::SendTransacSms.new(opts)
  end

  def formatted_content
    @content.tr("áâãëẽêíïîĩóôõúûũçÀÁÂÃÈËẼÊÌÍÏÎĨÒÓÔÕÙÚÛŨ", "aaaeeeiiiiooouuucAAAAEEEEIIIIIOOOOUUUU")
  end
end
