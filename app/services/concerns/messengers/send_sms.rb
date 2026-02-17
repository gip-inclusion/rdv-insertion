module Messengers::SendSms
  private

  def verify_format!(sendable)
    fail!("Envoi de SMS alors que le format est #{sendable.format}") unless sendable.format == "sms"
  end

  def verify_phone_number!(sendable)
    fail!("Le téléphone doit être renseigné") if sendable.phone_number.blank?
    fail!("Le numéro de téléphone doit être un mobile") unless sendable.phone_number_is_mobile?
    fail!("Le numéro de téléphone doit être un numéro français") unless sendable.phone_number_is_french?
  end

  def send_sms(sendable, content)
    return Rails.logger.info(content) if Rails.env.development?

    case sendable.sms_provider
    when "brevo"
      call_service!(Sms::SendWithBrevo, phone_number: sendable.phone_number,
                                        sender_name: sendable.sms_sender_name,
                                        content: content,
                                        record_identifier: sendable.record_identifier)
    when "primotexto"
      call_service!(Sms::SendWithPrimotexto, phone_number: sendable.phone_number,
                                             sender_name: sendable.sms_sender_name,
                                             content: content)
    else
      fail!("Le fournisseur de SMS n'est pas valide")
    end
  end
end
