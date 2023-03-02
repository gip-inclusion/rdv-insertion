module Messengers::SendEmail
  private

  def verify_format!(sendable)
    fail!("Envoi d'un email alors que le format est #{sendable.format}") unless sendable.format == "email"
  end

  def verify_email!(sendable)
    fail!("L'email doit être renseigné") if sendable.email.blank?
    return unless (sendable.email =~ URI::MailTo::EMAIL_REGEXP).nil?

    fail!("L'email renseigné ne semble pas être une adresse valable")
  end
end
