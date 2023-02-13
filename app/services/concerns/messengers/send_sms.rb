module Messengers::SendSms
  extend ActiveSupport::Concern

  included do
    before_call :verify_invitation_format!, :verify_phone_number!
  end

  private

  def verify_invitation_format!
    fail!("Envoi de SMS alors que le format est #{sendable.format}") unless sendable.format == "sms"
  end

  def verify_phone_number!
    fail!("Le téléphone doit être renseigné") if sendable.phone_number.blank?
    fail!("Le numéro de téléphone doit être un mobile") unless sendable.phone_number_is_mobile?
  end

  def send_sms
    return Rails.logger.info(content) if Rails.env.development?

    SendTransactionalSms.call(phone_number_formatted: sendable.phone_number_formatted,
                              sender_name: sendable.sms_sender_name, content: content)
  end

  def sendable
    raise NotImplementedError
  end
end
